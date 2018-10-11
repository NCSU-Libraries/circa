// UsersNewCtrl - inherits from UsersCtrl

var UsersNewCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {
  UsersCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  var _this = this;

  this.user = this.initializeUser();

  this.mode = 'new';
}

UsersNewCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
UsersNewCtrl.prototype = Object.create(UsersCtrl.prototype);
circaControllers.controller('UsersNewCtrl', UsersNewCtrl);
