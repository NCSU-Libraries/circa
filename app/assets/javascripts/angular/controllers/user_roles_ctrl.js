// Settings

var UserRolesCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {

  var _this = this;

  $scope.section = 'settings';

  CircaCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  $scope.updateLevels = function(index, sortDelta, callback) {
    _this.updateLevel($scope, index, sortDelta, callback);
  }

  $scope.updateUserRole = function() {
    _this.updateUserRole($scope);
  }

  $scope.createUserRole = function() {
    _this.createUserRole($scope);
  }

  $scope.mergeUserRoles = function() {
    _this.mergeUserRoles($scope);
  }

  $scope.currentUserAssignableRoleIds = function(roleId) {
    _this.currentUserAssignableRoleIds($scope);
  }

  $scope.updateLevels = function(index, delta) {
    _this.updateLevels($scope, index, delta);
  }

}

UserRolesCtrl.prototype = Object.create(CircaCtrl.prototype);
UserRolesCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('UserRolesCtrl', UserRolesCtrl);


UserRolesCtrl.prototype.getUserRolesList = function(scope, callback) {
  scope.loading = true;
  var _this = this;
  var path = '/user_roles';
  this.apiRequests.get(path).then(function(response) {
    scope.loading = false;
    if (response.status == 200) {
      scope.userRolesList = response.data['user_roles'];
      _this.commonUtils.executeCallback(callback, scope);
    }
    else {
      scope.error = response.data['error'];
    }
  });
}


UserRolesCtrl.prototype.getUserRole = function(scope, id, callback) {
  scope.loading = true;
  var _this = this;
  var path = '/user_roles/' + id;
  this.apiRequests.get(path).then(function(response) {
    scope.loading = false;
    if (response.status == 200) {
      scope.userRole = response.data['user_role'];
      _this.commonUtils.executeCallback(callback, scope);
    }
    else {
      scope.error = response.data['error'];
    }
  });
}


UserRolesCtrl.prototype.createUserRole = function(scope, callback) {
  scope.loading = true;
  var _this = this;
  var path = '/user_roles';
  this.apiRequests.post(path, { user_role: scope.userRole }).then(function(response) {
    scope.loading = false;
    if (response.status == 200) {
      _this.commonUtils.executeCallback(callback, scope);
      _this.goto('/settings/user_roles/list')
    }
    else {
      scope.error = response.data['error'];
    }
  });
}


UserRolesCtrl.prototype.updateUserRole = function(scope, callback) {
  scope.loading = true;
  var _this = this;
  var path = '/user_roles/' + scope.userRole.id;
  this.apiRequests.put(path, { user_role: scope.userRole }).then(function(response) {
    scope.loading = false;
    if (response.status == 200) {
      _this.commonUtils.executeCallback(callback, scope);
      _this.goto('/settings/user_roles/list')
    }
    else {
      scope.error = response.data['error'];
    }
  });
}


UserRolesCtrl.prototype.currentUserAssignableRoleIds = function(scope) {
  var roleIds = [];
  for (var i = 0; i < scope.currentUser.assignableRoles.length; i++) {
    roleIds.push(scope.currentUser.assignableRoles[i]['id']);
  }
  return roleIds;
}


UserRolesCtrl.prototype.updateLevels = function(scope, index, delta, callback) {
  var _this = this;

  var sorted_values = this.commonUtils.shiftPositionOfItemInArray(scope.userRolesList, index, delta)

  var postData = { user_roles: sorted_values };

  this.apiRequests.post('/user_roles/update_levels', postData).then(function(response) {
    scope.loading = false;
    if (response.status == 200) {
     scope.userRolesList = response.data['user_roles'];
      _this.commonUtils.executeCallback(callback, scope);
    }
    else {
      scope.error = response.data['error'];
    }
  });
}


UserRolesCtrl.prototype.mergeUserRoles = function(scope, callback) {
  scope.loading = true;
  var _this = this;
  var path = '/user_roles/merge';
  var putData = {
    merge_from_id: scope.userRole.id,
    merge_into_id: scope.mergeIntoId
  }
  this.apiRequests.put(path, putData).then(function(response) {
    scope.loading = false;
    if (response.status == 200) {
      _this.goto('/settings/user_roles/list');
    }
    else {
      scope.error = response.data['error'];
    }
  });
}
