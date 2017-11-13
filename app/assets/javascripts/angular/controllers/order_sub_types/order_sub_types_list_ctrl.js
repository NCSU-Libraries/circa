// Enumeration values list

var OrderSubTypesListCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {

  OrderSubTypesCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  this.getOrderSubTypes($scope);

}

OrderSubTypesListCtrl.prototype = Object.create(OrderSubTypesCtrl.prototype);
OrderSubTypesListCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('OrderSubTypesListCtrl', OrderSubTypesListCtrl);
