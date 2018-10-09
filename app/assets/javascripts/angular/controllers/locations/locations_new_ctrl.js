// LocationsNewCtrl - inherits from LocationsCtrl

var LocationsNewCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {
  LocationsCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);
  var _this = this;

  this.circaLocation = {};
}

LocationsNewCtrl.prototype = Object.create(LocationsCtrl.prototype);
LocationsNewCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('LocationsNewCtrl', LocationsNewCtrl);


LocationsNewCtrl.prototype.createLocation = function() {
  var _this = this;

  if (this.validateLocation()) {
    this.loading = true;
    this.apiRequests.post("/locations", { 'location': this.circaLocation }).then(function(response) {
      if (response.status == 200) {
       _this.sessionCache.refresh('circaLocations');
       _this.goto('/locations');
       _this.loading = false;
      }
    });
  }
  else {
    // alert
  }
}
