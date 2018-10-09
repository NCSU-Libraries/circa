// Settings

var UserRolesMergeCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  var _this = this;

  this.section = 'settings';

  UserRolesCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  // set mergeIntoUserRoles after cache loads to filter based on currentUser.assignable_roles
  var processCache = function(cache) {

    var setMergeIntoValues = function() {
      _this.mergeIntoUserRoles = [];
      for (var i = 0; i < _this.currentUser.assignable_roles.length; i++) {
        var role = _this.currentUser.assignable_roles[i];
        if (role.level > 1 && role.id != _this.userRole.id) {
          _this.mergeIntoUserRoles.push(role);
        }
      }
    }
    _this.processCache(cache);
    _this.getUserRole($routeParams.userRoleId, setMergeIntoValues);
  }

  var cache = sessionCache.init(processCache);

}

UserRolesMergeCtrl.prototype = Object.create(UserRolesCtrl.prototype);
UserRolesMergeCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('UserRolesMergeCtrl', UserRolesMergeCtrl);
