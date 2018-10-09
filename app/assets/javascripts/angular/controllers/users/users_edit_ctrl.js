// UsersEditCtrl - inherits from UsersCtrl

var UsersEditCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {
  UsersCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);
  var _this = this;

  // For edit views, load record after cache is loaded to ensure that controlled/enumerable values are ready
  var processCache = function(cache) {
    _this.processCache(cache);
    _this.getUser($routeParams.userId);
  }

  var cache = sessionCache.init(processCache);

  this.mode = 'edit';
}

UsersEditCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
UsersEditCtrl.prototype = Object.create(UsersCtrl.prototype);
circaControllers.controller('UsersEditCtrl', UsersEditCtrl);


UsersEditCtrl.prototype.updateUser = function() {
  var _this = this;

  if (this.validateUser()) {
    this.apiRequests.put("/users/" + this.user['id'], { 'user': this.user, 'user_type': 'researcher' }).then(function(response) {
      if (response.status == 200) {
        _this.user = response.data['user'];
        _this.goto('/users/' + _this.user['id']);
      }
      else if (response.data['error'] && response.data['error']['detail']) {
        _this.flash = response.data['error']['detail'];
      }
    });
  }
  else {
    // alert
  }

}
