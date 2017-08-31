OrderCtrl.prototype.applyItemFunctions = function(scope) {

  var _this = this;

  scope.removeItemOrder = function(itemOrder) {
    _this.removeItemOrder(scope, itemOrder);
  }

  scope.restoreItemOrder = function(itemOrder) {
    _this.restoreItemOrder(scope, itemOrder);
  }

  scope.deactivateItem = function(item) {
    _this.updateItemActivation(scope, item, 'deactivate');
  }

  scope.activateItem = function(item) {
    _this.updateItemActivation(scope, item, 'activate');
  }

}


OrderCtrl.prototype.getItemOrderIndex = function(itemOrders, itemId) {
  return itemOrders.findIndex(function(element, index, array) {
    return element['item_id'] == itemId;
  });
}


OrderCtrl.prototype.addItemOrder = function(scope, item, archivesspace_uri) {
  archivesspace_uri = archivesspace_uri ? [ archivesspace_uri ] : null;
  scope.order['item_orders'].push( { order_id: scope.order['id'], item_id: item['id'], item: item, archivesspace_uri: archivesspace_uri } );
}


OrderCtrl.prototype.removeItemOrder = function(scope, itemOrder, callback) {
  var _this = this;

  var removeItemOrderIndex = scope.order['item_orders'].findIndex(function(element) {
    return element['item_id'] == itemOrder['item_id'];
  });

  if (removeItemOrderIndex >= 0) {
    var removeItemOrder = scope.order['item_orders'].splice(removeItemOrderIndex, 1)[0];
    scope.removedItemOrders.push(removeItemOrder);
    scope.itemIds.splice( scope.itemIds.indexOf(removeItemOrder['item_id']), 1);
    _this.commonUtils.executeCallback(callback, scope);
    return true;
  }
}


OrderCtrl.prototype.restoreItemOrder = function(scope, itemOrder, callback) {
  var _this = this;
  var restoreItemOrderIndex = scope.removedItemOrders.findIndex(function(element) {
    return element['item_id'] == itemOrder['item_id'];
  });
  if (restoreItemOrderIndex >= 0) {
    var restoreItemOrder = scope.removedItemOrders.splice(restoreItemOrderIndex, 1);

    // ????
    restoreItemOrder = restoreItemOrder[0];

    // var item_order = { order_id: scope.order['id'], item_id: }
    scope.order['item_orders'].push(restoreItemOrder);
    scope.itemIds.push(itemOrder['item_id'])
    _this.commonUtils.executeCallback(callback, scope);
    return true;
  }
}

OrderCtrl.prototype.updateItemActivation = function(scope, item, method) {
  scope.itemEventLoading = true;
  var _this = this;
  var path = 'orders/' + scope.order.id
  if (method == 'activate') {
    path = path + '/activate_item';
  }
  else if (method == 'deactivate') {
    path = path + '/deactivate_item';
  }
  else {
    scope.flash = 'Invalid method supplied for updateItemAction';
    return
  }

  data = { item_id: item.id };

  this.apiRequests.put(path, data).then(function(response) {
    scope.itemEventLoading = false;
    if (response.status == 200) {
      _this.refreshOrder(scope, response.data['order'])
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
}
