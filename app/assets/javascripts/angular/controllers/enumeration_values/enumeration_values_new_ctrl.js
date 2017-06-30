// Enumeration values new

var EnumerationValuesNewCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {

  EnumerationValuesCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  $scope.enumerationValue = {
    value: '',
    value_short: '',
    enumeration_name: $routeParams.enumerationName
  };

  $scope.enumerationName = $routeParams.enumerationName;

  $scope.mode = 'new';

}

EnumerationValuesNewCtrl.prototype = Object.create(EnumerationValuesCtrl.prototype);
EnumerationValuesNewCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('EnumerationValuesNewCtrl', EnumerationValuesNewCtrl);
