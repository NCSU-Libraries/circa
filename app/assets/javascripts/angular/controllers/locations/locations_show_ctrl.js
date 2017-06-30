// LocationsShowCtrl - inherits from LocationsCtrl

var LocationsShowCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  LocationsCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);
  this.getLocation($scope, $routeParams.locationId);
}

LocationsShowCtrl.prototype = Object.create(LocationsCtrl.prototype);
LocationsShowCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('LocationsShowCtrl', LocationsShowCtrl);
