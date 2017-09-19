OrdersCtrl.prototype.spawn = function(scope, orderId) {
  var path = '/orders/' + id + '/clone';
  var _this = this;
  scope.loading = true;
  this.apiRequests.get(path).then(function(response) {
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
