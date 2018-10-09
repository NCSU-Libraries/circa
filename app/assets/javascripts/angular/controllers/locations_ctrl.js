// Locations

var LocationsCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  this.section = 'locations';

  CircaCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);
  if ($routeParams.locationId) {
    this.getLocation($routeParams.locationId);
  }
}

LocationsCtrl.prototype = Object.create(CircaCtrl.prototype);
LocationsCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('LocationsCtrl', LocationsCtrl);


LocationsCtrl.prototype.validateLocation = function() {
  // TBD
  return true;
}


