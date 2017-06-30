// Settings

var UserRolesEditCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {

  var _this = this;

  $scope.section = 'settings';

  UserRolesCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  this.getUserRole($scope, $routeParams.userRoleId);

}

UserRolesEditCtrl.prototype = Object.create(UserRolesCtrl.prototype);
UserRolesEditCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('UserRolesEditCtrl', UserRolesEditCtrl);
