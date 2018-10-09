// OrdersShowCtrl - For show view, inherits from OrdersCtrl

var OrdersShowCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {
  OrdersCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  var _this = this;

  var callback = function() {
    _this.initializeCheckOut();
    _this.setDefaultPrimaryUserId();
  }

  this.getOrder($routeParams.orderId, callback);

  this.usersLimit = 5;
  this.itemsLimit = 10;
  this.truncateUsers = true;
  this.truncateItems = true;
}


OrdersShowCtrl.prototype = Object.create(OrdersCtrl.prototype);
OrdersShowCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('OrdersShowCtrl', OrdersShowCtrl);


OrdersShowCtrl.prototype.calculatedUsersLimit = function() {
  return this.truncateUsers ? this.usersLimit : this.order.users.length
}


OrdersShowCtrl.prototype.calculatedItemsLimit = function() {
  return this.truncateItems ? this.itemsLimit : this.order.item_orders.length
}


OrdersShowCtrl.prototype.getOrderHistory = function() {
  var path = '/orders/' + this['order']['id'] + '/history';
  var _this = this;
  this.apiRequests.get(path).then(function(response) {
    if (response.status == 200) {
      _this['order']['history'] = response.data['order']['history'];
    }
    else {
      _this.error = response.data['error'];
    }
  });
}


OrdersShowCtrl.prototype.toggleTruncateUsers = function() {
  this.truncateUsers = (this.truncateUsers == false) ? true : false;
}


OrdersShowCtrl.prototype.toggleTruncateItems = function() {
  this.truncateItems = (this.truncateItems == false) ? true : false;
}
