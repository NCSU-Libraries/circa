// LocationsListCtrl - inherits from LocationsCtrl

var LocationsListCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  LocationsCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  this.deletedRecordFlash('location');
}

LocationsListCtrl.prototype = Object.create(LocationsCtrl.prototype);
LocationsListCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('LocationsListCtrl', LocationsListCtrl);
