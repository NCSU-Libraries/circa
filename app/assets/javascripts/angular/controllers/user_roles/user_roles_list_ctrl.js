// Settings

var UserRolesListCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  var _this = this;

  this.section = 'settings';

  UserRolesCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  this.getUserRolesList();

}

UserRolesListCtrl.prototype = Object.create(UserRolesCtrl.prototype);
UserRolesListCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('UserRolesListCtrl', UserRolesListCtrl);
