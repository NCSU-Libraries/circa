// Settings

var UserRolesNewCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {

  var _this = this;

  $scope.section = 'settings';

  UserRolesCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  $scope.userRole = { name: '' };

}

UserRolesNewCtrl.prototype = Object.create(UserRolesCtrl.prototype);
UserRolesNewCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('UserRolesNewCtrl', UserRolesNewCtrl);
