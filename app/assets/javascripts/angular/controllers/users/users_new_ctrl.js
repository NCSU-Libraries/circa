// UsersNewCtrl - inherits from UsersCtrl

var UsersNewCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {
  UsersCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  var _this = this;

  this.user = this.initializeUser();

  this.mode = 'new';
}

UsersNewCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
UsersNewCtrl.prototype = Object.create(UsersCtrl.prototype);
circaControllers.controller('UsersNewCtrl', UsersNewCtrl);


UsersNewCtrl.prototype.attributesFromLdap = function() {
  var _this = this;

  var uid = this['user']['findUid'].trim();
  uid = encodeURIComponent(uid);

  if (uid) {
    var path = "/users/attributes_from_ldap";
    var conf = { params: { uid: uid } }

    this.apiRequests.get(path, conf).then(function(response) {
      if (response.status == 200) {
        _this['findUid'] = '';
        _this.commonUtils.objectMerge(_this.user, response.data['user']);
      }
      else if (response.data['error'] && response.data['error']['detail']) {
        _this.flash = response.data['error']['detail'];
      }
    });
  }
}
