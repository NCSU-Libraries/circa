// Settings

var UserRolesEditCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  var _this = this;

  this.section = 'settings';

  UserRolesCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  this.getUserRole($routeParams.userRoleId);

}

UserRolesEditCtrl.prototype = Object.create(UserRolesCtrl.prototype);

UserRolesEditCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];

circaControllers.controller('UserRolesEditCtrl', UserRolesEditCtrl);
