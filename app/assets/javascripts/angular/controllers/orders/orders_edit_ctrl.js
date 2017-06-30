// OrdersEditCtrl - For edit view, inherits from OrderCtrl

var OrdersEditCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  OrderCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  var _this = this;

  $scope.mode = 'edit';

  var callback = function(scope) {
    _this.setStatesEvents(scope);
    _this.setDefaultPrimaryUserId(scope);
    if (!scope.order['temporary_location']) {
      scope.order['temporary_location'] = scope.defaultLocation;
      scope.order['default_location'] = true;
    }
  }

  // For edit views, load record after cache is loaded to ensure that controlled/enumerable values are ready
  $scope.processCache = function(cache) {
    _this.processCache(cache, $scope);
    _this.getOrder($scope, $routeParams.orderId, callback);
  }

  var cache = sessionCache.init($scope.processCache);

  $scope.updateOrder = function() {
    _this.updateOrder($scope, $location);
  }
}


OrdersEditCtrl.prototype = Object.create(OrderCtrl.prototype);


OrdersEditCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];


circaControllers.controller('OrdersEditCtrl', OrdersEditCtrl);


OrdersEditCtrl.prototype.updateOrder = function(scope) {
  var _this = this;

  if (scope.order['default_location']) {
    scope.order['temporary_location'] = scope.defaultLocation;
  }

  if (_this.validateOrder(scope)) {
    scope.loading = true;
    _this.apiRequests.put("orders/" + scope.order['id'], { 'order': scope.order }).then(function(response) {
      if (response.status == 200) {
       scope.order = response.data['order'];
       _this.goto('orders/' + scope.order['id']);
       scope.loading = false;
      }
      else if (response.data['error'] && response.data['error']['detail']) {
        scope.flash = response.data['error']['detail'];
      }
    });
  }
  else {
    _this.window.scroll(0,0);
  }
}
