// UsersShowCtrl - inherits from UsersCtrl

var UsersShowCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  UsersCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);
  this.getUser($scope, $routeParams.userId);
}

UsersShowCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
UsersShowCtrl.prototype = Object.create(UsersCtrl.prototype);
circaControllers.controller('UsersShowCtrl', UsersShowCtrl);
