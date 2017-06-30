// Locations

var LocationsCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {

  $scope.section = 'locations';

  CircaCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);
  if ($routeParams.locationId) {
    this.getLocation($scope, $routeParams.locationId);
  }
}

LocationsCtrl.prototype = Object.create(CircaCtrl.prototype);
LocationsCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('LocationsCtrl', LocationsCtrl);


LocationsCtrl.prototype.validateLocation = function(scope) {
  // TBD
  return true;
}


