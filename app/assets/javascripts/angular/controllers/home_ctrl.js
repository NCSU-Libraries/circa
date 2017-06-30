// UsersShowCtrl - inherits from UsersCtrl

var HomeCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  CircaCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);


}

HomeCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
HomeCtrl.prototype = Object.create(CircaCtrl.prototype);
circaControllers.controller('HomeCtrl', HomeCtrl);
