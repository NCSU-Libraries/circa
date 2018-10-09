CircaCtrl.prototype.showUser = function(userId) {
  this.goto('users/' + userId);
}


CircaCtrl.prototype.editUser = function(userId) {
  this.goto('users/' + userId + '/edit');
}


CircaCtrl.prototype.getUser = function(userId, callback) {
  this.loading = true;
  var path = '/users/' + userId;
  var _this = this;
  // var params = { user_type: 'user' };
  var params = {};

  this.apiRequests.get(path, { 'params': params } ).then(function(response) {
    if (response.status == 200) {
      _this.loading = false;
      _this.refreshUser(response.data['user'], callback)
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      this.flash = response.data['error']['detail'];
    }
  });
}


CircaCtrl.prototype.createUser = function() {
  var _this = this;

  if (this.validateUser()) {
    this.apiRequests.post("/users", { 'user': this.user }).then(function(response) {
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
    _this.window.scroll(0,0);
  }
}


CircaCtrl.prototype.validateUser = function() {
  var valid = true;
  this.user.validationErrors = {};
  this.user.hasValidationErrors = false;
  var _this = this;

  $.each(this.requiredUserFields(), function(index, value) {
    if (!_this.user[value]) {
      _this.user.validationErrors[value] = 'Required';
    }
  });

  // Validate email
  var emailRegex = /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/;
  if (!this.user['email'].match(emailRegex)) {
    this.user.validationErrors['email'] = 'Email address is not valid';
  }

  if (Object.keys(this.user.validationErrors).length > 0) {
    valid = false;
    this.user.hasValidationErrors = true;
  }

  return valid;
}


CircaCtrl.prototype.requiredUserFields = function() {
  // return ['email', 'first_name', 'last_name', 'researcher_type_id', 'address1', 'city', 'state', 'zip', 'country', 'phone'];
  return [ 'email', 'first_name', 'last_name', 'researcher_type_id', 'state', 'country' ];
}



CircaCtrl.prototype.refreshUser = function(user, callback) {
  this.user = user;
  this.user['open_orders'] = this.user['orders'].filter(function(o) { return o['open']; });
  this.user['completed_orders'] = this.user['orders'].filter(function(o) { return !o['open']; });
  this.commonUtils.executeCallback(callback);
}


// Collect associated user emails to avoid duplication
CircaCtrl.prototype.collectUserEmails = function(order) {
  var _this = this;
  this.userEmails = this.userEmails || [];

  if (Array.isArray(order['users'])) {
    order['users'].forEach(function(user) {
      _this.userEmails.push(user['email'])
    });
  }
}


// Collect associated assignee emails to avoid duplication
CircaCtrl.prototype.collectAssigneeEmails = function(order) {
  var _this = this;
  this.assigneeEmails = (typeof this.assigneeEmails === 'undefined') ? [] : this.assigneeEmails;
  if (Array.isArray(order['assignees'])) {
    $.each(order['assignees'], function(index, user) {
      _this.assigneeEmails.push(user['email']);
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
    role: 'researcher',
    notes: []
  }
}
