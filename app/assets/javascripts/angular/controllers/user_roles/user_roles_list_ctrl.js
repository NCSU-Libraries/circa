// Settings

var UserRolesListCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {

  var _this = this;

  $scope.section = 'settings';

  UserRolesCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  this.getUserRolesList($scope);

}

UserRolesListCtrl.prototype = Object.create(UserRolesCtrl.prototype);
UserRolesListCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('UserRolesListCtrl', UserRolesListCtrl);
