// Enumeration values list

var OrderSubTypesEditCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {

  var _this = this;

  OrderSubTypesCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  // For edit views, load record after cache is loaded to ensure that controlled/enumerable values are ready
  var processCache = function(cache) {
    _this.processCache(cache, $scope);
    _this.getOrderSubType($scope, $routeParams.orderSubTypeId);
  }

  var cache = sessionCache.init(processCache);

  $scope.mode = 'edit';

}

OrderSubTypesEditCtrl.prototype = Object.create(OrderSubTypesCtrl.prototype);
OrderSubTypesEditCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('OrderSubTypesEditCtrl', OrderSubTypesEditCtrl);
