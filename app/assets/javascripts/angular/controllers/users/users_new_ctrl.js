// UsersNewCtrl - inherits from UsersCtrl

var UsersNewCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  UsersCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  var _this = this;

  $scope.user = this.initializeUser();

  $scope.mode = 'new';

  $scope.createUser = function() {
    _this.createUser($scope);
  }

  $scope.attributesFromLdap = function() {
    _this.attributesFromLdap($scope);
  }
}

UsersNewCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
UsersNewCtrl.prototype = Object.create(UsersCtrl.prototype);
circaControllers.controller('UsersNewCtrl', UsersNewCtrl);


UsersNewCtrl.prototype.createUser = function(scope) {
  var _this = this;

  if (_this.validateUser(scope)) {
    _this.apiRequests.post("/users", { 'user': scope.user }).then(function(response) {
      if (response.status == 200) {
        scope.user = response.data['user'];
        _this.goto('/users/' + scope.user['id']);
      }
      else if (response.data['error'] && response.data['error']['detail']) {
        scope.flash = response.data['error']['detail'];
      }
    });
  }
  else {
    _this.window.scroll(0,0);
  }
}


UsersNewCtrl.prototype.attributesFromLdap = function(scope) {
  var _this = this;

  var uid = scope['user']['findUid'].trim();
  uid = encodeURIComponent(uid);

  if (uid) {
    var path = "/users/attributes_from_ldap";
    var conf = { params: { uid: uid } }
    this.apiRequests.get(path, conf).then(function(response) {
      if (response.status == 200) {
        scope['findUid'] = '';
        _this.commonUtils.objectMerge(scope.user, response.data['user']);
      }
      else if (response.data['error'] && response.data['error']['detail']) {
        scope.flash = response.data['error']['detail'];
      }
    });
  }
}
