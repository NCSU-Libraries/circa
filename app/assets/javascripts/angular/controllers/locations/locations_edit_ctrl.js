// LocationsEditCtrl - inherits from LocationsCtrl

var LocationsEditCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {
  LocationsCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);
  var _this = this;
  this.getLocation($routeParams.locationId);
}

LocationsEditCtrl.prototype = Object.create(LocationsCtrl.prototype);
LocationsEditCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('LocationsEditCtrl', LocationsEditCtrl);


LocationsEditCtrl.prototype.updateLocation = function() {
  var _this = this;
  var path = "/locations/" + this.circaLocation['id'];

  if (_this.validateLocation()) {
    _this.apiRequests.put(path, { 'location': _this.circaLocation }).then(function(response) {
      if (response.status == 200) {
       _this.sessionCache.refresh('circaLocations');
       _this.goto('/locations');
      }
    });
  }
  else {
    // alert
  }
}
