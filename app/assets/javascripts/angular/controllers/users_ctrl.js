// UsersCtrl - inherits from CircaCtrl

var UsersCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  CircaCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);
  var _this = this;
  $scope.section = 'users';
  $scope.validationErrors = {};
  $scope.hasValidationErrors = false;
  $scope.sort = 'last_name asc';

  this.initializeFilterConfig($scope);

  $scope.addNote = function(user) {
    user = user || $scope.user;
    console.log('adding user note');
    _this.addNote($scope, user);
  }

  $scope.removeNote = function(index, user) {
    user = user || $scope.user;
    _this.removeNote($scope, user, index);
  }

  $scope.restoreNote = function(note, user) {
    user = user || $scope.user;
    _this.restoreNote($scope, user, note);
  }

  $scope.sendPasswordResetLink = function(user) {
    _this.sendPasswordResetLink($scope, user);
  }

}

UsersCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];

UsersCtrl.prototype = Object.create(CircaCtrl.prototype);


UsersCtrl.prototype.getPage = function(scope, page) {
  this.getUsers(scope, page);
}


UsersCtrl.prototype.getUsers = function(scope, page) {
  scope.loading = true;
  var path = '/users';
  var _this = this;
  page = page ? page : 1;
  scope.page = page;

  var config = this.listRequestConfig(scope);
  this.updateLocationQueryParams(config['params']);

  this.apiRequests.getPage(path, page, config).then(function(response) {
    scope.loading = false;
    if (response.status == 200) {
      scope.users = response.data['users'];
      var paginationParams = _this.commonUtils.paginationParams(response.data['meta']['pagination']);
      _this.commonUtils.objectMerge(scope, paginationParams);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
}


UsersCtrl.prototype.requiredUserFields = function() {
  // return ['email', 'first_name', 'last_name', 'patron_type_id', 'address1', 'city', 'state', 'zip', 'country', 'phone'];
  return [ 'email', 'first_name', 'last_name', 'patron_type_id', 'state', 'country' ];
}


UsersCtrl.prototype.validateUser = function(scope) {
  var valid = true;
  scope.user.validationErrors = {};
  scope.user.hasValidationErrors = false;

  $.each(this.requiredUserFields(), function(index, value) {
    if (!scope.user[value]) {
      scope.user.validationErrors[value] = 'Required';
    }
  });

  // Validate email
  var emailRegex = /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/;
  if (!scope.user['email'].match(emailRegex)) {
    scope.user.validationErrors['email'] = 'Email address is not valid';
  }

  if (Object.keys(scope.user.validationErrors).length > 0) {
    valid = false;
    scope.user.hasValidationErrors = true;
  }

  console.log(scope.user.validationErrors);

  return valid;
}


UsersCtrl.prototype.sendPasswordResetLink = function(scope, user) {
  var path = '/users/' + user.id + '/send_password_reset_link';
  var _this = this;

  this.apiRequests.get(path).then(function(response) {
    if (response.status == 200) {
      scope.flash = "Password reset link has been sent to " + user.email;
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
}
