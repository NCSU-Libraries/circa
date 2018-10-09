// Settings

var UserRolesNewCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  var _this = this;

  this.section = 'settings';

  UserRolesCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  this.userRole = { name: '' };

}

UserRolesNewCtrl.prototype = Object.create(UserRolesCtrl.prototype);
UserRolesNewCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('UserRolesNewCtrl', UserRolesNewCtrl);
