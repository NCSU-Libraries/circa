// UsersListCtrl - inherits from UsersCtrl

var UsersListCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  UsersCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  this.processListParams($scope);
  this.getUsers($scope, $scope.page);

}

UsersListCtrl.$inject = [ '$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
UsersListCtrl.prototype = Object.create(UsersCtrl.prototype);
circaControllers.controller('UsersListCtrl', UsersListCtrl);
