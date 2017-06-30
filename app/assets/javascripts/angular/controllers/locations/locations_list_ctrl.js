// LocationsListCtrl - inherits from LocationsCtrl

var LocationsListCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  LocationsCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);
}

LocationsListCtrl.prototype = Object.create(LocationsCtrl.prototype);
LocationsListCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('LocationsListCtrl', LocationsListCtrl);
