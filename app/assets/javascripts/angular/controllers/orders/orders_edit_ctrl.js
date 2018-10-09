// OrdersEditCtrl - For edit view, inherits from OrdersCtrl

var OrdersEditCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {
  OrdersCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  var _this = this;

  this.mode = 'edit';

  var callback = function() {
    _this.setStatesEvents();
    _this.setDefaultPrimaryUserId();
  }

  this.initializeOrderFormComponents();

  this.getOrder($routeParams.orderId, callback);

  // For edit views, load record after cache is loaded to ensure that controlled/enumerable values are ready
  var processCache = function(cache) {
    _this.processCache(cache);
    // _this.getOrder($routeParams.orderId, callback);
  }

  var cache = sessionCache.init(processCache);
}


OrdersEditCtrl.prototype = Object.create(OrdersCtrl.prototype);


OrdersEditCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];


circaControllers.controller('OrdersEditCtrl', OrdersEditCtrl);


OrdersEditCtrl.prototype.validateAndUpdateOrder = function() {
  if (this.validateOrder()) {
    this.updateOrder();
  }
  else {
    this.window.scroll(0,0);
  }
}


OrdersEditCtrl.prototype.enableUpdateOrderType = function() {
  this.order['updateOrderTypeEnabled'] = true;
}
