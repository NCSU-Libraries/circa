// Enumeration values list

var OrderSubTypesEditCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  var _this = this;

  OrderSubTypesCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  // For edit views, load record after cache is loaded to ensure that controlled/enumerable values are ready
  var processCache = function(cache) {
    _this.processCache(cache);
    _this.getOrderSubType($routeParams.orderSubTypeId);
  }

  var cache = sessionCache.init(processCache);

  this.mode = 'edit';

}

OrderSubTypesEditCtrl.prototype = Object.create(OrderSubTypesCtrl.prototype);
OrderSubTypesEditCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('OrderSubTypesEditCtrl', OrderSubTypesEditCtrl);
