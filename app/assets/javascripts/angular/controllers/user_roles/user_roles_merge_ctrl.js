// Settings

var UserRolesMergeCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {

  var _this = this;

  $scope.section = 'settings';

  UserRolesCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  // set mergeIntoUserRoles after cache loads to filter based on currentUser.assignable_roles
  var processCache = function(cache) {
    var setMergeIntoValues = function(scope) {
      scope.mergeIntoUserRoles = [];
      for (var i = 0; i < scope.currentUser.assignable_roles.length; i++) {
        var role = scope.currentUser.assignable_roles[i];
        if (role.level > 1 && role.id != scope.userRole.id) {
          scope.mergeIntoUserRoles.push(role);
        }
      }
    }
    _this.processCache(cache, $scope);
    _this.getUserRole($scope, $routeParams.userRoleId, setMergeIntoValues);
  }

  var cache = sessionCache.init(processCache);

}

UserRolesMergeCtrl.prototype = Object.create(UserRolesCtrl.prototype);
UserRolesMergeCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('UserRolesMergeCtrl', UserRolesMergeCtrl);
