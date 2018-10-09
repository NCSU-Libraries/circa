// UsersListCtrl - inherits from UsersCtrl

var UsersListCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {
  UsersCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  this.processListParams();
  this.getUsers(this.page);

}

UsersListCtrl.$inject = [ '$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
UsersListCtrl.prototype = Object.create(UsersCtrl.prototype);
circaControllers.controller('UsersListCtrl', UsersListCtrl);
