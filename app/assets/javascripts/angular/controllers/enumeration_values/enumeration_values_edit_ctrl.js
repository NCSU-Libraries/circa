// Enumeration values list

var EnumerationValuesEditCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {

  EnumerationValuesCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  this.getEnumerationValue($scope, $routeParams.enumerationValueId);

  $scope.mode = 'edit';

}

EnumerationValuesEditCtrl.prototype = Object.create(EnumerationValuesCtrl.prototype);
EnumerationValuesEditCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('EnumerationValuesEditCtrl', EnumerationValuesEditCtrl);
