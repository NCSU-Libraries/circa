// Enumeration values list

var EnumerationValuesListCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {

  EnumerationValuesCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  $scope.enumerationName = $routeParams.enumerationName;

  this.getEnumerationValuesList($scope, $routeParams.enumerationName);

}

EnumerationValuesListCtrl.prototype = Object.create(EnumerationValuesCtrl.prototype);
EnumerationValuesListCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('EnumerationValuesListCtrl', EnumerationValuesListCtrl);
