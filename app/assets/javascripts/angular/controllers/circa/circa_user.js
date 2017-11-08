CircaCtrl.prototype.applyUserFunctions = function(scope) {

  var _this = this;

  scope.showUser = function(userId) {
    _this.showUser(userId);
  }

  scope.editUser = function(userId) {
    _this.editUser(userId);
  }

}


CircaCtrl.prototype.showUser = function(userId) {
  this.goto('users/' + userId);
}


CircaCtrl.prototype.editUser = function(userId) {
  this.goto('users/' + userId + '/edit');
}


CircaCtrl.prototype.getUser = function(scope, userId, callback) {
  scope.loading = true;
  var path = '/users/' + userId;
  var _this = this;
  // var params = { user_type: 'user' };
  var params = {};

  this.apiRequests.get(path, { 'params': params } ).then(function(response) {
    if (response.status == 200) {
      scope.loading = false;
      _this.refreshUser(scope, response.data['user'], callback)
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
}


CircaCtrl.prototype.refreshUser = function(scope, user, callback) {
  scope.user = user;
  scope.user['open_orders'] = scope.user['orders'].filter(function(o) { return o['open']; });
  scope.user['completed_orders'] = scope.user['orders'].filter(function(o) { return !o['open']; });
  this.commonUtils.executeCallback(callback, scope);
}


// Collect associated user emails to avoid duplication
CircaCtrl.prototype.collectUserEmails = function(scope, order) {
  scope.userEmails = (typeof scope.userEmails === 'undefined') ? [] : scope.userEmails;
  function addEmailToScope(element, index, array) {
    scope.userEmails.push(element['email'])
  }
  if (Array.isArray(order['users'])) {
    order['users'].forEach(addEmailToScope);
  }
}


// Collect associated assignee emails to avoid duplication
CircaCtrl.prototype.collectAssigneeEmails = function(scope, order) {
  scope.assigneeEmails = (typeof scope.assigneeEmails === 'undefined') ? [] : scope.assigneeEmails;
  if (Array.isArray(order['assignees'])) {
    $.each(order['assignees'], function(index, user) {
      scope.assigneeEmails.push(user['email']);
    });
  }
}


CircaCtrl.prototype.initializeUser = function() {
  return {
    email: '',
    first_name: '', last_name: '',
    position: '', affiliation: '',
    display_name: '',
    address1: '', address2: '', city: '', state: 'NC', zip: '', country: 'US', phone: '', agreement_confirmed_at: '',
    role: 'patron',
    notes: []
  }
}

