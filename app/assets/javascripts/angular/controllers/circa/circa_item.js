CircaCtrl.prototype.applyItemFunctions = function(scope) {

  var _this = this;

  scope.showItem = function(itemId) {
    _this.showItem(itemId);
  }

  scope.showItemHistory = function(itemId) {
    _this.showItemHistory(itemId);
  }

  scope.triggerItemEvent = function(itemId, event, callback) {
    _this.triggerItemEvent(scope, itemId, event, callback);
  }

  scope.initializeCheckOut = function(itemId, orderId) {
    _this.initializeCheckOut(scope, itemId, orderId);
  }

  scope.checkOutItem = function(item, users, callback) {
    _this.checkOutItem(scope, item, users, callback);
  }

  scope.receiveItemAtTemporaryLocation = function(item, callback) {
    _this.receiveItemAtTemporaryLocation(scope, item, callback)
  }

  scope.checkInItem = function(item, callback) {
    _this.checkInItem(scope, item, callback);
  }

  scope.enableItemLocationChange = function(item) {
    _this.enableItemLocationChange(scope, item);
  }

  scope.changeItemLocation = function() {
    _this.changeItemLocation(scope);
  }

  scope.bulkItemEvents = function() {
    return _this.bulkItemEvents(scope);
  }

  scope.bulkTriggerItemEvent = function(event) {
    _this.bulkTriggerItemEvent(scope, event);
  }

}


CircaCtrl.prototype.showItem = function(itemId) {
  this.goto('items/' + itemId);
}


CircaCtrl.prototype.showItemHistory = function(itemId) {
  this.goto('items/' + itemId + '/history');
}


CircaCtrl.prototype.setCheckOutAvailable = function(scope) {
  if (scope.order) {
    if (scope.order['order_type']['name'] == 'research') {
      scope.order['checkOutAvailable'] = true;
    }
    else {
      scope.order['checkOutAvailable'] = false;
    }
  }
}


// Trigger event for item
CircaCtrl.prototype.triggerItemEvent = function(scope, itemId, event, callback) {
  var path = '/items/' + itemId + '/' + event;
  var _this = this;
  var data = { 'order_id': scope.order['id'] };
  scope.itemEventLoading = true;
  _this.apiRequests.put(path, data).then(function(response) {

    scope.itemEventLoading = false;

    if (response.status == 200) {

      if (scope.order && response.data['order']) {
        scope.order = response.data['order'];
      }
      else if (scope.order && !response.data['order']) {
        _this.updateOrder(scope);
      }

      _this.commonUtils.executeCallback(callback, response.data);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
}


CircaCtrl.prototype.bulkTriggerItemEvent = function(scope, event) {
  var _this = this;
  if (scope.order && scope.order['item_orders']) {
    scope.order['item_orders'].forEach(function(item_order) {
      var item = item_order['item'];
      if (item['permitted_events'].indexOf(event) >= 0) {
        if (event == 'receive_at_temporary_location') {
          _this.receiveItemAtTemporaryLocation(scope, item)
        }
        else {
          _this.triggerItemEvent(scope, item['id'], event);
        }
      }
    });
  }
}


CircaCtrl.prototype.bulkItemEvents = function(scope) {
  var skipEvents = [ 'report_not_found', 'check_out' ]
  if (scope.order && scope.order['item_orders']) {
    var bulkEvents = {};
    scope.order['item_orders'].forEach(function(item_order) {
      var item = item_order['item'];
      if (!item['obsolete']) {
        item['permitted_events'].forEach(function(event) {
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
    });
    return bulkEvents;
  }
}


CircaCtrl.prototype.initializeCheckOut = function(scope) {
  var _this = this;
  scope.checkOutItemIds = [];
  scope.checkOutUserIds = [];
  scope.availableUsers = {};
  scope.toggleCheckout = function(itemId) {
    _this.commonUtils.toggleArrayElement(scope.checkOutItemIds, itemId);
  }

  if (scope.order && scope.order['users']) {
    $.each(scope.order['users'], function(index, user) {
      scope.availableUsers[user['id']] = user;
    });

    if (scope.order['users'].length == 1 && scope.order['users'][0]['agreement_confirmed']) {
      scope.checkOutUserIds.push(parseInt(scope.order['users'][0]['id']));
    }
  }
}


CircaCtrl.prototype.enableItemLocationChange = function(scope, item) {
  scope.itemLocationChangeEnabled = item['id'];
  scope.itemLocationChange = { 'item': item, 'locationId': item['current_location']['id'].toString() };
}


CircaCtrl.prototype.changeItemLocation = function(scope) {
  var _this = this;
  if (scope.itemLocationChange) {
    var item = scope.itemLocationChange['item'];
    var itemId = item['id'];
    var locationId = scope.itemLocationChange['locationId'];
    if (itemId && locationId) {
      item['current_location_id'] = locationId;
      var path = '/items/' + item['id'];
      var postData = { 'item': item };
      scope.itemLocationChange['loading'] = true;
      this.apiRequests.put(path, postData).then(function(response) {
        if (response.status == 200) {
          if (scope.order) {
            _this.getOrder(scope, scope.order['id']);
          }
          else if (scope.item) {
            _this.getItem(scope, scope.item['id']);
          }
          scope.itemLocationChangeEnabled = null;
          scope.itemLocationChange = { 'item': null, 'locationId': null };
        }
        else {
          if (response.data['error'] && response.data['error']['detail']) {
            scope.itemLocationChange['alert'] = response.data['error']['detail'];
          }
          else {
            scope.itemLocationChange['alert'] = "Unknown error"
          }
        }
      });
    }
  }
}


// Check out item
CircaCtrl.prototype.checkOutItem = function(scope, item, userIds, callback) {
  var _this = this;
  var path = '/items/' + item['id'] + '/check_out';
  var users = scope.order['users'].filter(function(user) {
    return userIds.indexOf(user['id']) >= 0;
  });

  var data = { 'users': users, 'order_id': scope.order['id'] };

  this.apiRequests.put(path, data).then(function(response) {
    if (response.status == 200) {

      if (scope.order) {
        _this.getOrder(scope, scope.order['id']);
      }
      else if (scope.item) {
        _this.getItem(scope, scope.item['id']);
      }
      _this.initializeCheckOut(scope);
      _this.commonUtils.executeCallback(callback, response.data);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
}


// Check in item
CircaCtrl.prototype.checkInItem = function(scope, item, callback) {
  scope.itemEventLoading = true;
  var _this = this;
  var path = '/items/' + item['id'] + '/check_in';
  var data = { 'order_id': scope.order['id'] };
  this.apiRequests.put(path, data).then(function(response) {
    scope.itemEventLoading = false;
    if (response.status == 200) {
      if (scope.order) {
        _this.getOrder(scope, scope.order['id']);
      }
      else if (scope.item) {
        _this.getItem(scope, scope.item['id']);
      }
      _this.initializeCheckOut(scope);
      _this.commonUtils.executeCallback(callback, response.data);
    }
  });
}


// Check out item
CircaCtrl.prototype.receiveItemAtTemporaryLocation = function(scope, item, callback) {
  scope.itemEventLoading = true;
  var _this = this;
  var path = '/items/' + item['id'] + '/receive_at_temporary_location';
  var data = { 'order_id': scope.order['id'] };

  this.apiRequests.put(path, data).then(function(response) {
    scope.itemEventLoading = false;
    if (response.status == 200) {

      if (scope.order) {
        _this.getOrder(scope, scope.order['id']);
      }
      else if (scope.item) {
        _this.getItem(scope, scope.item['id']);
      }
      _this.commonUtils.executeCallback(callback, response.data);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
}


// Collect associated item IDs to avoid duplication
CircaCtrl.prototype.collectItemIds = function(scope, order) {
  scope.itemIds = (typeof scope.itemIds === 'undefined') ? [] : scope.itemIds;

  function addItemIdsToScope(item) {
    if (scope.itemIds.indexOf(item['id'] < 0)) {
      scope.itemIds.push(item['id']);
    }
  }

  if (Array.isArray(order['item_orders'])) {
    order['item_orders'].forEach( function(item_order, i, array) {
      addItemIdsToScope(item_order['item']);
    });
  }
}
