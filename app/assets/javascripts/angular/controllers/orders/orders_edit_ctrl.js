// OrdersEditCtrl - For edit view, inherits from OrdersCtrl

var OrdersEditCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  OrdersCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  var _this = this;

  $scope.mode = 'edit';

  var callback = function(scope) {
    _this.setStatesEvents(scope);
    _this.setDefaultPrimaryUserId(scope);
    _this.applyFunctionsToScope(scope);

    // if (!scope.order['temporary_location']) {
    //   scope.order['temporary_location'] = scope.defaultLocation;
    //   scope.order['default_location'] = true;
    // }
  }

  // For edit views, load record after cache is loaded to ensure that controlled/enumerable values are ready
  var processCache = function(cache) {
    _this.processCache(cache, $scope);
    _this.getOrder($scope, $routeParams.orderId, callback);
  }

  var cache = sessionCache.init(processCache);

  $scope.validateAndUpdateOrder = function() {
    _this.validateAndUpdateOrder($scope, $location);
  }

  $scope.enableUpdateOrderType = function() {
    _this.enableUpdateOrderType($scope);
  }

}


OrdersEditCtrl.prototype = Object.create(OrdersCtrl.prototype);


OrdersEditCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];


circaControllers.controller('OrdersEditCtrl', OrdersEditCtrl);


OrdersEditCtrl.prototype.validateAndUpdateOrder = function(scope) {
  if (this.validateOrder(scope)) {
    this.updateOrder(scope);
  }
  else {
    this.window.scroll(0,0);
  }
}


OrdersEditCtrl.prototype.enableUpdateOrderType = function(scope) {
  scope.order['updateOrderTypeEnabled'] = true;
}
