// LocationsEditCtrl - inherits from LocationsCtrl

var LocationsEditCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  LocationsCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);
  var _this = this;
  this.getLocation($scope, $routeParams.locationId);
  $scope.updateLocation = function() {
    _this.updateLocation($scope, sessionCache);
  }
}

LocationsEditCtrl.prototype = Object.create(LocationsCtrl.prototype);
LocationsEditCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('LocationsEditCtrl', LocationsEditCtrl);


LocationsEditCtrl.prototype.updateLocation = function(scope, sessionCache) {
  var _this = this;
  var path = "/locations/" + scope.location['id'];

  if (_this.validateLocation()) {
    _this.apiRequests.put(path, { 'location': scope.location }).then(function(response) {
      if (response.status == 200) {
       sessionCache.refresh('circaLocations');
       _this.goto('/locations');
      }
    });
  }
  else {
    // alert
  }
}
