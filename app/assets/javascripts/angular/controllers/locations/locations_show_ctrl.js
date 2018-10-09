// LocationsShowCtrl - inherits from LocationsCtrl

var LocationsShowCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {
  LocationsCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);
  this.getLocation($routeParams.locationId);
}

LocationsShowCtrl.prototype = Object.create(LocationsCtrl.prototype);
LocationsShowCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('LocationsShowCtrl', LocationsShowCtrl);
