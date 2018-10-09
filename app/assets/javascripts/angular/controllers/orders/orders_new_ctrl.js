// OrdersNewCtrl - For new view, inherits from OrdersCtrl

var OrdersNewCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {
  OrdersCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  var _this = this;

  this.mode = 'new';

  this.initializeOrderFormComponents();

  // make user selectors visible for new orders
  // this.userSelect.show = true

  this.newOrder();

  if ($routeParams.userId) {
    var addUserToNewOrder = function() {
      _this.order['users'].push(_this.user);
    }
    this.getUser($routeParams.userId, addUserToNewOrder);
  }
}

OrdersNewCtrl.prototype = Object.create(OrdersCtrl.prototype);
OrdersNewCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('OrdersNewCtrl', OrdersNewCtrl);
