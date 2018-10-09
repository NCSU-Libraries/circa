// Initialize object used to manage user selection
OrdersCtrl.prototype.initializeUserSelect = function() {
  return {
    email: '',
    loading: false,
    alert: null,
    q: '',
    list: [],
    show: false
  };
}


OrdersCtrl.prototype.showUserSelector = function() {
  this.userSelect.show = true;
}


OrdersCtrl.prototype.showAssigneeSelector = function() {
  this.assigneeSelect.show = true;
}


OrdersCtrl.prototype.closeAssigneeSelector = function() {
  this.assigneeSelect.show = false;
}


OrdersCtrl.prototype.closeUserSelector = function() {
  this.userSelect.show = false;
}


OrdersCtrl.prototype.addUser = function(user) {
  if (user) {
    var email = user['email'];

    if (this.userEmails.indexOf(email) >= 0) {
      this.userSelect.alert = 'A user with email ' + email + ' is already associated with this order.';
    }
    else {
      this.order['users'].push(user);
      this.userEmails.push(email);
      this.setDefaultPrimaryUserId();
    }
  }
}


OrdersCtrl.prototype.addAssignee = function(user) {
  if (user) {
    var email = user['email'];

    if (this.assigneeEmails.indexOf(email) >= 0) {
      this.assigneeSelect['alert'] = 'A user with email ' + email + ' is already assigned to this order.';
    }
    else {
      this.order['assignees'].push(user);
      this.assigneeEmails.push(email);
    }
  }
}


OrdersCtrl.prototype.selectUser = function(user) {
  this.addUser(user);
  this.userSelect = this.initializeUserSelect();
}


OrdersCtrl.prototype.selectAssignee = function(user) {
  this.addAssignee(user);
  this.assigneeSelect = this.initializeUserSelect();
}


OrdersCtrl.prototype.updateUserSelectList = function() {
  var _this = this;

  if (this.userSelect.q == '') {
    this.userSelect.list = []
  }
  else {
    this.apiRequests.get("/user_typeahead/" + this.userSelect.q ).then(function(response) {
      if (response.status == 200) {
        _this.userSelect.list = response.data['users'];
      }
    });
  }
}


OrdersCtrl.prototype.updateAssigneeSelectList = function() {
  var _this = this;
  if (this.assigneeSelect.q == '') {
    this.assigneeSelect.list = []
  }
  else {
    this.apiRequests.get("/staff_user_typeahead/" + this.assigneeSelect.q ).then(function(response) {
      if (response.status == 200) {
        _this.assigneeSelect.list = response.data['users'];
      }
    });
  }
}


OrdersCtrl.prototype.openNewUserModal = function() {
  this.showNewUserModal = true;
  this.user = this.initializeUser();
}


OrdersCtrl.prototype.closeNewUserModal = function() {
  this.showNewUserModal = false;
  this.user = null;
}


OrdersCtrl.prototype.createAndAddUser = function() {
  var _this = this;

  if (this.validateUser()) {
    this.apiRequests.post("/users", { 'user': this.user }).then(function(response) {
      if (response.status == 200) {
        var user = response.data['user'];
        _this.closeNewUserModal();
        _this.order['users'].push(user);
        _this.userEmails.push(user.email);
      }
      else if (response.data['error'] && response.data['error']['detail']) {
        _this.flash = response.data['error']['detail'];
      }
    });
  }
}


OrdersCtrl.prototype.removeUser = function(user) {
  this.removeUserOrAssignee('users', user);
  if (this.order.users.length == 0) {
    this.userSelect.show = true;
  }
}


OrdersCtrl.prototype.removeAssignee = function(user) {
  this.removeUserOrAssignee('assignees', user);
}


OrdersCtrl.prototype.removeUserOrAssignee = function(association, user, callback) {
  var removeUserIndex = this.order[association].findIndex(function(element, index, array) {
    return element['id'] == user['id'];
  });

  if (removeUserIndex >= 0) {
    var removeUser = this.order[association].splice(removeUserIndex, 1);
    removeUser = removeUser[0];
    if (association == 'users') {
      this.removedUsers.push(removeUser);
      this.setDefaultPrimaryUserId();
    }
    else if (association == 'assignees') {
      this.removedAssignees.push(removeUser);
    }

    this.commonUtils.executeCallback(callback);

    return true;
  }
}


OrdersCtrl.prototype.restoreUser = function(user) {
  this.restoreUserOrAssignee('users', user);
  this.userSelect.show = false;
}


OrdersCtrl.prototype.restoreAssignee= function(user) {
  this.restoreUserOrAssignee('assignees', user);
  this.assigneeSelect.show = false;
}


OrdersCtrl.prototype.restoreUserOrAssignee = function(association, user, callback) {
  var restoreUserIndex;

  var findIndexCallback = function(element, index, array) {
    return element['id'] == user['id'];
  }

  if (association == 'users') {
    restoreUserIndex = this.removedUsers.findIndex(findIndexCallback);
  }
  else if (association == 'assignees') {
    restoreUserIndex = this.removedAssignees.findIndex(findIndexCallback);
  }

  if (restoreUserIndex >= 0) {
    var restoreUser;

    if (association == 'users') {
      restoreUser = this.removedUsers.splice(restoreUserIndex, 1);
    }
    else if (association == 'assignees') {
      restoreUser = this.removedAssignees.splice(restoreUserIndex, 1);
    }

    restoreUser = restoreUser[0];
    this.order[association].push(restoreUser);
    this.commonUtils.executeCallback(callback);
    return true;
  }
}


OrdersCtrl.prototype.setUserLabel = function() {
  var userLabels = {
    research: 'researcher',
    reproduction: 'requester',
    exhibition: 'requester',
    processing: 'user'
  };

  this.userLabel = this.order['order_type'] ?
      userLabels[this.order['order_type']['name']] : 'user';
}


OrdersCtrl.prototype.setPrimaryUserId = function(userId) {
  this.order['primary_user_id'] = userId;
}


OrdersCtrl.prototype.toggleRemoteUser = function(user) {
  user.remote = user.remote ? false : true;
}


OrdersCtrl.prototype.setDefaultPrimaryUserId = function() {
  if (!this.order['primary_user_id'] && this.order['users']) {
    if (this.order['users'][0]) {
      this.order['primary_user_id'] = this.order['users'][0]['id'];
    }
  }
}
