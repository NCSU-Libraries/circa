OrdersCtrl.prototype.getItemOrderIndex = function(itemOrders, itemId) {
  return itemOrders.findIndex(function(element, index, array) {
    return element['item_id'] == itemId;
  });
}


OrdersCtrl.prototype.addItemOrder = function(item, archivesspace_uri) {
  archivesspace_uri = archivesspace_uri ? [ archivesspace_uri ] : null;
  var itemOrder = { order_id: this.order['id'], item_id: item['id'],
      item: item, archivesspace_uri: archivesspace_uri };
  if (this.order['order_type']['name'] == 'reproduction') {
    itemOrder['reproduction_spec'] = { pages: 1 };
  }
  this.order['item_orders'].push( itemOrder );
}


OrdersCtrl.prototype.removeItemOrder = function(itemOrder, callback) {
  var _this = this;

  var removeItemOrderIndex = this.order['item_orders'].findIndex(function(element) {
    return element['item_id'] == itemOrder['item_id'];
  });

  if (removeItemOrderIndex >= 0) {
    var removeItemOrder = this.order['item_orders'].splice(removeItemOrderIndex, 1)[0];
    this.removedItemOrders.push(removeItemOrder);
    this.itemIds.splice(this.itemIds.indexOf(removeItemOrder['item_id']), 1);
    _this.commonUtils.executeCallback(callback);
    return true;
  }
}


OrdersCtrl.prototype.restoreItemOrder = function(itemOrder, callback) {
  var _this = this;

  var restoreItemOrderIndex = this.removedItemOrders.findIndex(function(element) {
    return element['item_id'] == itemOrder['item_id'];
  });

  if (restoreItemOrderIndex >= 0) {
    var restoreItemOrder = this.removedItemOrders.splice(restoreItemOrderIndex, 1);

    // ????
    restoreItemOrder = restoreItemOrder[0];

    this.order['item_orders'].push(restoreItemOrder);
    this.itemIds.push(itemOrder['item_id'])
    this.commonUtils.executeCallback(callback);
    return true;
  }
}


OrdersCtrl.prototype.updateItemActivation = function(item, method) {
  this.itemEventLoading = true;
  var _this = this;
  var path = 'orders/' + this.order.id

  if (method == 'activate') {
    path = path + '/activate_item';
  }
  else if (method == 'deactivate') {
    path = path + '/deactivate_item';
  }
  else {
    this.flash = 'Invalid method supplied for updateItemAction';
    return
  }

  data = { item_id: item.id };

  this.apiRequests.put(path, data).then(function(response) {
    _this.itemEventLoading = false;
    if (response.status == 200) {
      _this.refreshOrder(response.data['order'])
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.flash = response.data['error']['detail'];
    }
  });
}


OrdersCtrl.prototype.deactivateItem = function(item) {
  this.updateItemActivation(item, 'deactivate');
}


OrdersCtrl.prototype.activateItem = function(item) {
  this.updateItemActivation(item, 'activate');
}


OrdersCtrl.prototype.closeItemSelector = function() {
  this.showItemSelector = false;
}
