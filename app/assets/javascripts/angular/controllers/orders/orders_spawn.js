OrdersCtrl.prototype.spawn = function(scope, orderId, orderSubTypeId) {
  scope.loading = true;
  var _this = this;
  var postData = orderSubTypeId ? { order: { spawn: { order_sub_type_id: orderSubTypeId } } } : {}
  var path = '/orders/' + id + '/spawn';
  this.apiRequests.post(path, postData).then(function(response) {
    if (response.status == 200) {
      var orderId = response.data['order']['id']
      this.goto('orders/' + orderId);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.errorCode = response.status;
      scope.flash = response.data['error']['detail'];
    }
  });
}
