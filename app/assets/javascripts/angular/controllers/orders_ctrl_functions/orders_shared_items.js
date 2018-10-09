OrdersCtrl.prototype.deactivatedOrderIds = function(item) {
  var activeOrderIds = item.active_orders.map(x => x.id);
  var openOrderIds = item.open_orders.map(x => x.id);
  return openOrderIds.filter(x => activeOrderIds.indexOf(x) < 0);
}


OrdersCtrl.prototype.otherDeactivatedOrderIds = function(item) {
  var orderId = this.order.id
  var deactivatedOrderIds = this.deactivatedOrderIds(item);
  return deactivatedOrderIds.filter(x => x != orderId);
}


OrdersCtrl.prototype.activeOrderIds = function(item) {
  return item.active_orders.map(x => x.id);
}


OrdersCtrl.prototype.otherActiveOrderIds = function(item) {
  var orderId = this.order.id
  var activeOrderIds = this.activeOrderIds(item);
  return activeOrderIds.filter(x => x != orderId);
}
