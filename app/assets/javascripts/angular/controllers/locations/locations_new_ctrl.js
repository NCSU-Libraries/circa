// LocationsNewCtrl - inherits from LocationsCtrl

var LocationsNewCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  LocationsCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);
  var _this = this;

  $scope.location = {};

  $scope.createLocation = function() {
    _this.createLocation($scope, sessionCache);
  }

}

LocationsNewCtrl.prototype = Object.create(LocationsCtrl.prototype);
LocationsNewCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('LocationsNewCtrl', LocationsNewCtrl);



LocationsNewCtrl.prototype.createLocation = function(scope, sessionCache) {
  var _this = this;

  if (_this.validateLocation()) {
    scope.loading = true;
    _this.apiRequests.post("/locations", { 'location': scope.location }).then(function(response) {
      if (response.status == 200) {
       // scope.location = response.data['location'];
       sessionCache.refresh('circaLocations');
       _this.goto('/locations');
       scope.loading = false;
      }
    });
  }
  else {
    // alert
  }

}
