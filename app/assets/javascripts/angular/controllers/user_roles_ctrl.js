// Settings

var UserRolesCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  this.section = 'settings';

  CircaCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);
}

UserRolesCtrl.prototype = Object.create(CircaCtrl.prototype);
UserRolesCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('UserRolesCtrl', UserRolesCtrl);


UserRolesCtrl.prototype.getUserRolesList = function(callback) {
  this.loading = true;
  var _this = this;
  var path = '/user_roles';
  this.apiRequests.get(path).then(function(response) {
    _this.loading = false;
    if (response.status == 200) {
      _this.userRolesList = response.data['user_roles'];
      _this.commonUtils.executeCallback(callback);
    }
    else {
      _this.error = response.data['error'];
    }
  });
}


UserRolesCtrl.prototype.getUserRole = function(id, callback) {
  this.loading = true;
  var _this = this;
  var path = '/user_roles/' + id;
  this.apiRequests.get(path).then(function(response) {
    _this.loading = false;
    if (response.status == 200) {

      console.log(response.data['user_role']);

      _this.userRole = response.data['user_role'];
      _this.commonUtils.executeCallback(callback);
    }
    else {
      _this.error = response.data['error'];
    }
  });
}


UserRolesCtrl.prototype.createUserRole = function(callback) {
  this.loading = true;
  var _this = this;
  var path = '/user_roles';
  this.apiRequests.post(path, { user_role: this.userRole }).then(function(response) {
    _this.loading = false;
    if (response.status == 200) {
      _this.commonUtils.executeCallback(callback);
      _this.goto('/settings/user_roles')
    }
    else {
      _this.error = response.data['error'];
    }
  });
}


UserRolesCtrl.prototype.updateUserRole = function(callback) {
  this.loading = true;
  var _this = this;
  var path = '/user_roles/' + this.userRole.id;
  this.apiRequests.put(path, { user_role: this.userRole }).then(function(response) {
    _this.loading = false;
    if (response.status == 200) {
      _this.commonUtils.executeCallback(callback);
      _this.goto('/settings/user_roles')
    }
    else {
      _this.error = response.data['error'];
    }
  });
}


UserRolesCtrl.prototype.currentUserAssignableRoleIds = function() {
  var roleIds = [];
  for (var i = 0; i < this.currentUser.assignableRoles.length; i++) {
    roleIds.push(this.currentUser.assignableRoles[i]['id']);
  }
  return roleIds;
}


UserRolesCtrl.prototype.updateLevels = function(index, delta, callback) {
  var _this = this;

  var sorted_values = this.commonUtils.shiftPositionOfItemInArray(this.userRolesList, index, delta)

  var postData = { user_roles: sorted_values };

  this.apiRequests.post('/user_roles/update_levels', postData).then(function(response) {
    _this.loading = false;
    if (response.status == 200) {
      _this.userRolesList = response.data['user_roles'];
      _this.commonUtils.executeCallback(callback);
    }
    else {
      _this.error = response.data['error'];
    }
  });
}


UserRolesCtrl.prototype.mergeUserRoles = function(callback) {
  this.loading = true;
  var _this = this;
  var path = '/user_roles/merge';
  var putData = {
    merge_from_id: this.userRole.id,
    merge_into_id: this.mergeIntoId
  }
  this.apiRequests.put(path, putData).then(function(response) {
    _this.loading = false;
    if (response.status == 200) {
      _this.goto('/settings/user_roles/list');
    }
    else {
      _this.error = response.data['error'];
    }
  });
}
