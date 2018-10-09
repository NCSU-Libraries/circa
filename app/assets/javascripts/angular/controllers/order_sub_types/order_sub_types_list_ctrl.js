// Enumeration values list

var OrderSubTypesListCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  OrderSubTypesCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  this.getOrderSubTypes();

}

OrderSubTypesListCtrl.prototype = Object.create(OrderSubTypesCtrl.prototype);
OrderSubTypesListCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('OrderSubTypesListCtrl', OrderSubTypesListCtrl);
