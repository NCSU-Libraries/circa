CircaCtrl.prototype.showItem = function(itemId) {
  this.goto('items/' + itemId);
}


CircaCtrl.prototype.showItemHistory = function(itemId) {
  this.goto('items/' + itemId + '/history');
}


CircaCtrl.prototype.setCheckOutAvailable = function() {
  if (this.order) {
    if (this.order['order_type']['name'] == 'research') {
      this.order['checkOutAvailable'] = true;
    }
    else {
      this.order['checkOutAvailable'] = false;
    }
  }
}


// Trigger event for item
CircaCtrl.prototype.triggerItemEvent = function(itemId, event, callback) {
  var path = '/items/' + itemId + '/' + event;
  var _this = this;
  var data = { 'order_id': this.order['id'] };
  this.itemEventLoading = true;
  this.apiRequests.put(path, data).then(function(response) {

    _this.itemEventLoading = false;

    if (response.status == 200) {

      if (_this.order && response.data['order']) {
        _this.order = response.data['order'];
      }
      else if (_this.order && !response.data['order']) {
        _this.refreshCurrentOrder(callback);
      }

      _this.commonUtils.executeCallback(callback, response.data);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.flash = response.data['error']['detail'];
    }
  });
}


CircaCtrl.prototype.availableStateEvents = function(item) {
  var available = [];
  var _this = this;

  function verifyStateEvent(stateEvent, index) {
    var availableEvents = item.available_events_per_order[_this.order.id];
    if (availableEvents && availableEvents.indexOf(stateEvent['event']) >= 0) {
      available.push(stateEvent);
    }
  }

  item['states_events'].forEach(verifyStateEvent);

  return available;
}


CircaCtrl.prototype.bulkTriggerItemEvent = function(event) {
  var _this = this;

  function eventPermitted(item) {
    var specialEvents = ['update_from_source'];
    var permittedEvents = item['permitted_events'].concat(specialEvents);
    return permittedEvents.indexOf(event) >= 0
  }

  if (this.order && this.order['item_orders']) {
    this.order['item_orders'].forEach(function(itemOrder) {

      if (_this.order['bulkEventsList'].indexOf(itemOrder.id) >= 0) {
        var item = itemOrder['item'];

        if (eventPermitted(item)) {
          if (event == 'receive_at_temporary_location') {
            _this.receiveItemAtTemporaryLocation(item)
          }
          else {
            _this.triggerItemEvent(item['id'], event);
          }
        }

      }
    });
  }
}


CircaCtrl.prototype.updateBulkItemEvents = function() {
  var _this = this;

  var skipEvents = [ 'report_not_found', 'check_out' ];

  if (this.order && this.order['item_orders']) {
    var bulkEvents = {};

    this.order['item_orders'].forEach(function(itemOrder) {

      if (_this.order['bulkEventsList'].indexOf(itemOrder.id) >= 0) {

        var item = itemOrder['item'];
        if (!item['obsolete']) {

          var availableEvents = _this.availableStateEvents(item).map(function(stateEvent) {
            return stateEvent['event'];
          });

          // item['permitted_events'].forEach(function(event) {
          availableEvents.forEach(function(event) {
            if (skipEvents.indexOf(event) < 0) {
              if (!bulkEvents[event]) {
                bulkEvents[event] = 1;
              }
              else {
                bulkEvents[event]++;
              }
            }
          });
        }
      }
    });

    bulkEvents['update_from_source'] = this.order['item_orders'].length;
    this.order['bulkItemEvents'] = bulkEvents;
  }
}


CircaCtrl.prototype.addItemOrderIdToBulkEventsList = function(itemOrder) {
  if (this.order) {
    if (!this.order['bulkEventsList']) {
      this.order['bulkEventsList'] = [];
    }
    this.order['bulkEventsList'].push(itemOrder.id);
    itemOrder['inBulkEventsList'] = true;
  }
  this.updateBulkItemEvents();
}


CircaCtrl.prototype.removeItemOrderIdFromBulkEventsList = function(itemOrder) {
  if (this.order && this.order['bulkEventsList']) {
    this.commonUtils.removeFromArray(this.order['bulkEventsList'], itemOrder.id);
    itemOrder['inBulkEventsList'] = false;
  }
  this.updateBulkItemEvents();
}


CircaCtrl.prototype.addAllItemOrdersToBulkEventsList = function() {
  var _this = this;
  if (this.order && this.order['item_orders']) {
    this.order['item_orders'].forEach(function(itemOrder) {
      _this.addItemOrderIdToBulkEventsList(itemOrder);
    });
  }
  this.updateBulkItemEvents();
}


CircaCtrl.prototype.clearBulkEventsList = function() {
  this.order['bulkEventsList'] = [];
  this.updateBulkItemEvents();
}


CircaCtrl.prototype.toggleItemOrderIdInBulkEventsList = function(itemOrder) {
  if (this.order['bulkEventsList'].indexOf(itemOrder.id) < 0) {
    this.addItemOrderIdToBulkEventsList(itemOrder);
  }
  else {
    this.removeItemOrderIdFromBulkEventsList(itemOrder);
  }
}


CircaCtrl.prototype.initializeCheckOut = function() {
  var _this = this;
  this.checkOutItemIds = [];
  this.checkOutUserIds = [];
  this.availableUsers = {};
  this.toggleCheckout = function(itemId) {
    _this.commonUtils.toggleArrayElement(this.checkOutItemIds, itemId);
  }

  if (this.order && this.order['users']) {
    $.each(this.order['users'], function(index, user) {
      _this.availableUsers[user['id']] = user;
    });

    if (this.order['users'].length == 1 && this.order['users'][0]['agreement_confirmed']) {
      this.checkOutUserIds.push(parseInt(this.order['users'][0]['id']));
    }
  }
}


CircaCtrl.prototype.enableItemLocationChange = function(item) {
  this.itemLocationChangeEnabled = item['id'];
  this.itemLocationChange = { 'item': item, 'locationId': item['current_location']['id'].toString() };
}


CircaCtrl.prototype.changeItemLocation = function() {
  var _this = this;
  if (this.itemLocationChange) {
    var item = this.itemLocationChange['item'];
    var itemId = item['id'];
    var locationId = this.itemLocationChange['locationId'];
    if (itemId && locationId) {
      item['current_location_id'] = locationId;
      var path = '/items/' + item['id'];
      var postData = { 'item': item };
      this.itemLocationChange['loading'] = true;
      this.apiRequests.put(path, postData).then(function(response) {
        if (response.status == 200) {
          if (_this.order) {
            _this.getOrder(_this.order['id']);
          }
          else if (_this.item) {
            _this.getItem(_this.item['id']);
          }
          _this.itemLocationChangeEnabled = null;
          _this.itemLocationChange = { 'item': null, 'locationId': null };
        }
        else {
          if (response.data['error'] && response.data['error']['detail']) {
            _this.itemLocationChange['alert'] = response.data['error']['detail'];
          }
          else {
            _this.itemLocationChange['alert'] = "Unknown error"
          }
        }
      });
    }
  }
}


// Check out item
CircaCtrl.prototype.checkOutItem = function(item, userIds, callback) {
  var _this = this;
  var path = '/items/' + item['id'] + '/check_out';
  var users = this.order['users'].filter(function(user) {
    return userIds.indexOf(user['id']) >= 0;
  });

  var data = { 'users': users, 'order_id': this.order['id'] };

  this.apiRequests.put(path, data).then(function(response) {
    if (response.status == 200) {

      if (_this.order) {
        _this.getOrder(_this.order['id']);
      }
      else if (_this.item) {
        _this.getItem(_this.item['id']);
      }
      _this.initializeCheckOut();
      _this.commonUtils.executeCallback(callback, response.data);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.flash = response.data['error']['detail'];
    }
  });
}


// Check in item
CircaCtrl.prototype.checkInItem = function(item, callback) {
  this.itemEventLoading = true;
  var _this = this;
  var path = '/items/' + item['id'] + '/check_in';
  var data = { 'order_id': this.order['id'] };
  this.apiRequests.put(path, data).then(function(response) {
    _this.itemEventLoading = false;
    if (response.status == 200) {
      if (_this.order) {
        _this.getOrder(_this.order['id']);
      }
      else if (_this.item) {
        _this.getItem(_this.item['id']);
      }
      _this.initializeCheckOut();
      _this.commonUtils.executeCallback(callback, response.data);
    }
  });
}


// Check out item
CircaCtrl.prototype.receiveItemAtTemporaryLocation = function(item, callback) {
  this.itemEventLoading = true;
  var _this = this;
  var path = '/items/' + item['id'] + '/receive_at_temporary_location';
  var data = { 'order_id': this.order['id'] };

  this.apiRequests.put(path, data).then(function(response) {
    _this.itemEventLoading = false;
    if (response.status == 200) {

      if (_this.order) {
        _this.getOrder(_this.order['id']);
      }
      else if (_this.item) {
        _this.getItem(_this.item['id']);
      }
      _this.commonUtils.executeCallback(callback, response.data);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.flash = response.data['error']['detail'];
    }
  });
}


// Collect associated item IDs to avoid duplication
CircaCtrl.prototype.collectItemIds = function(order) {
  this.itemIds = (typeof this.itemIds === 'undefined') ? [] : this.itemIds;
  var _this = this;

  // function addItemIdsToScope(item) {
  //   if (scope.itemIds.indexOf(item['id'] < 0)) {
  //     scope.itemIds.push(item['id']);
  //   }
  // }

  if (Array.isArray(order['item_orders'])) {
    order['item_orders'].forEach( function(item_order, i, array) {
      var item = item_order['item'];
      if (_this.itemIds.indexOf(item['id'] < 0)) {
        _this.itemIds.push(item['id']);
      }
    });
  }
}


CircaCtrl.prototype.updateItemFromSource = function(itemId) {
  this.loading = true;
  var path = '/items/' + itemId + '/update_from_source';
  var _this = this;
  this.apiRequests.put(path).then(function(response) {
    _this.loading = false;
    if (response.status == 200) {
      _this.item = response.data['item'];
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.flash = response.data['error']['detail'];
    }
  });
}
