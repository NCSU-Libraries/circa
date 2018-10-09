// UsersShowCtrl - inherits from UsersCtrl

var UsersShowCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {
  UsersCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);
  this.getUser($routeParams.userId);
}

UsersShowCtrl.$inject = [ '$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils' ];
UsersShowCtrl.prototype = Object.create(UsersCtrl.prototype);
circaControllers.controller('UsersShowCtrl', UsersShowCtrl);
