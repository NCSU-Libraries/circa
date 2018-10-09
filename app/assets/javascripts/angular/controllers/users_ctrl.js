// UsersCtrl - inherits from CircaCtrl

var UsersCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  CircaCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  this.section = 'users';
  this.validationErrors = {};
  this.hasValidationErrors = false;
  this.sort = 'last_name asc';

  this.initializeFilterConfig();
}

UsersCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];

UsersCtrl.prototype = Object.create(CircaCtrl.prototype);


UsersCtrl.prototype.getPage = function(page) {
  this.getUsers(page);
}


UsersCtrl.prototype.getUsers = function(page) {
  this.loading = true;
  var path = '/users';
  var _this = this;
  page = page ? page : 1;
  this.page = page;

  var config = this.listRequestConfig();
  this.updateLocationQueryParams(config['params']);

  this.apiRequests.getPage(path, page, config).then(function(response) {
    _this.loading = false;
    if (response.status == 200) {
      _this.users = response.data['users'];
      var paginationParams = _this.commonUtils.paginationParams(response.data['meta']['pagination']);
      _this.commonUtils.objectMerge(_this, paginationParams);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.flash = response.data['error']['detail'];
    }
  });
}


// UsersCtrl.prototype.requiredUserFields = function() {
//   // return ['email', 'first_name', 'last_name', 'researcher_type_id', 'address1', 'city', 'state', 'zip', 'country', 'phone'];
//   return [ 'email', 'first_name', 'last_name', 'researcher_type_id', 'state', 'country' ];
// }


UsersCtrl.prototype.sendPasswordResetLink = function(user) {
  var path = '/users/' + user.id + '/send_password_reset_link';
  var _this = this;

  this.apiRequests.get(path).then(function(response) {
    if (response.status == 200) {
      _this.flash = "Password reset link has been sent to " + user.email;
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.flash = response.data['error']['detail'];
    }
  });
}
