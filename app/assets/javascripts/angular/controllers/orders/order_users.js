OrderCtrl.prototype.applyUserFunctions = function(scope) {
  var _this = this;

  scope.addUser = function(item) {
    _this.addUser(scope, item);
  }

  scope.addAssignee = function(item) {
    _this.addAssignee(scope, item);
  }

  scope.removeUser = function(user) {
    _this.removeUserOrAssignee(scope, 'users', user);
  }

  scope.removeAssignee = function(user) {
    _this.removeUserOrAssignee(scope, 'assignees', user);
  }

  scope.restoreUser = function(user) {
    _this.restoreUserOrAssignee(scope, 'users', user);
  }

  scope.restoreAssignee = function(user) {
    _this.restoreUserOrAssignee(scope, 'assignees', user);
  }

  scope.createAndAddUser = function() {
    _this.createAndAddUser(scope);
  }

  scope.createAndAddAssignee = function() {
    _this.createAndAddAssignee(scope);
  }

}


// Initialize object used to manage user selection
OrderCtrl.prototype.initializeUserSelect = function(scope) {
  return { 'email': '', 'loading': false, 'alert': null };
}


OrderCtrl.prototype.addUser = function(scope, item) {
  var _this = this;

  if (item) {

    // var email = scope.userSelect['email'];
    var user = item.originalObject;
    var email = item.originalObject['email'];

    scope.userSelect['loading'] = true;
    scope.userSelect['alert'] = null;

    scope.userSelect = _this.initializeUserSelect();
    scope.$broadcast('angucomplete-alt:clearInput', 'userSelectEmail');

    if (scope.userEmails.indexOf(email) >= 0) {
      // scope.userSelect = _this.initializeUserSelect();
      scope.userSelect['alert'] = 'A user with email ' + email + ' is already associated with this order.';
    }
    else {
      // scope.userSelect = _this.initializeUserSelect();
      scope.order['users'].push(user);
      scope.userEmails.push(email);
      _this.setDefaultPrimaryUserId(scope);
    }
  }
}


OrderCtrl.prototype.openNewUserModal = function(scope) {
  var _this = this;
  _this.window.scroll(0,0);
  return _this.modal.open({
    templateUrl: _this.templateUrl('users/new_modal'),
    controller: 'UsersNewModalInstanceCtrl',
    scope: scope,
    parent: 'main',
    resolve: {
      resolved: function() {
        return {
          user: _this.initializeUser(),
          find_unity_id: ''
        }
      }
    }
  });
}


OrderCtrl.prototype.createAndAddUser = function(scope) {
  var _this = this;

  var scrollY = _this.window.scrollY;

  var modalInstance = _this.openNewUserModal();

  modalInstance.result.then(function (result) {

    console.log(result);

    scope.order['users'].push(result['user']);
    scope.userEmails.push( result['user']['email'] );
    _this.window.scroll(0,scrollY);
  }, function () {
    console.log('Modal dismissed at: ' + new Date());
    _this.window.scroll(0,scrollY);
  });
}


OrderCtrl.prototype.addAssignee = function(scope, item) {
  var _this = this;
  if (item) {
    var assignee = item.originalObject;
    var email = item.originalObject['email'];

    scope.assigneeSelect['loading'] = true;
    scope.assigneeSelect['alert'] = null;

    scope.assigneeSelect = _this.initializeUserSelect();

    if (scope.assigneeEmails.indexOf(email) >= 0) {
      scope.assigneeSelect['alert'] = 'A user with email ' + email + ' is already associated with this order.';
    }
    else {
      scope.order['assignees'].push(assignee);
      scope.assigneeEmails.push(email);
    }
  }
}


OrderCtrl.prototype.createAndAddAssignee = function(scope) {
  var _this = this;

  var scrollY = _this.window.scrollY;

  var modalInstance = _this.openNewUserModal();

  modalInstance.result.then(function (result) {
    scope.order['assignees'].push(result['user']);
    _this.window.scroll(0,scrollY);
  }, function () {
    console.log('Modal dismissed at: ' + new Date());
    _this.window.scroll(0,scrollY);
  });
}


OrderCtrl.prototype.removeUserOrAssignee = function(scope, association, user, callback) {
  var _this = this;

  var removeUserIndex = scope.order[association].findIndex(function(element, index, array) {
    return element['id'] == user['id'];
  });

  if (removeUserIndex >= 0) {
    var removeUser = scope.order[association].splice(removeUserIndex, 1);
    removeUser = removeUser[0];
    if (association == 'users') {
      scope.removedUsers.push(removeUser);
      _this.setDefaultPrimaryUserId(scope);
    }
    else if (association == 'assignees') {
      scope.removedAssignees.push(removeUser);
    }

    _this.commonUtils.executeCallback(callback, scope);

    return true;
  }
}


OrderCtrl.prototype.restoreUserOrAssignee = function(scope, association, user, callback) {
  var _this = this;
  var restoreUserIndex;
  var findIndexCallback = function(element, index, array) {
    return element['id'] == user['id'];
  }

  if (association == 'users') {
    restoreUserIndex = scope.removedUsers.findIndex(findIndexCallback);
  }
  else if (association == 'assignees') {
    restoreUserIndex = scope.removedAssignees.findIndex(findIndexCallback);
  }

  if (restoreUserIndex >= 0) {
    var restoreUser;

    if (association == 'users') {
      restoreUser = scope.removedUsers.splice(restoreUserIndex, 1);
    }
    else if (association == 'assignees') {
      restoreUser = scope.removedAssignees.splice(restoreUserIndex, 1);
    }

    restoreUser = restoreUser[0];
    scope.order[association].push(restoreUser);
    _this.commonUtils.executeCallback(callback, scope);
    return true;
  }
}


// OrderCtrl.prototype.removeUser = function(scope, user, callback) {
//   var _this = this;

//   console.log(user);

//   var removeUserIndex = scope.order['users'].findIndex(function(element, index, array) {
//     return element['id'] == user['id'];
//   });

//   console.log(removeUserIndex);

//   if (removeUserIndex >= 0) {
//     var removeUser = scope.order['users'].splice(removeUserIndex, 1);
//     removeUser = removeUser[0];
//     scope.removedUsers.push(removeUser);
//     _this.setDefaultPrimaryUserId(scope);
//     _this.commonUtils.executeCallback(callback, scope);

//     console.log(scope.removedUsers);

//     return true;
//   }
// }


OrderCtrl.prototype.restoreUser = function(scope, user, callback) {
  var _this = this;
  var restoreUserIndex = scope.removedUsers.findIndex(function(element, index, array) {
    return element['id'] == user['id'];
  });
  if (restoreUserIndex >= 0) {
    var restoreUser = scope.removedUsers.splice(restoreUserIndex, 1);
    restoreUser = restoreUser[0];
    scope.order['users'].push(restoreUser);
    _this.commonUtils.executeCallback(callback, scope);
    return true;
  }
}


OrderCtrl.prototype.userLabel = function(scope) {
  var userLabels = {
    research: 'researcher',
    reproduction: 'requester',
    exhibition: 'requester',
    processing: 'user'
  };

  return scope.order['order_type'] ? userLabels[ scope.order['order_type']['name'] ] : 'user';
}

