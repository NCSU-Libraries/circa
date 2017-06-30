var UsersNewModalInstanceCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils, $modalInstance, resolved) {

  UsersNewCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  var _this = this;

  commonUtils.objectMerge($scope, resolved);

  $scope.newUser = {};

  $scope.newUser['user'] = this.initializeUser();

  $scope.newUser.attributesFromLdap = function() {
    _this.attributesFromLdap($scope.newUser);
  }


  $scope.ok = function (data) {
    if (_this.validateUser($scope.newUser)) {

      _this.apiRequests.post("/users", { 'user': $scope.newUser['user'], 'user_type': 'patron' }).then(function(response) {
        if (response.status == 200) {
          $modalInstance.close(response.data);
        }
        else if (response.data['error'] && response.data['error']['detail']) {
          $scope.flash = response.data['error']['detail'];
        }
      });

    }
    else {
      _this.window.scroll(0,0);
    }
  }

  $scope.dismiss = function () {
    $modalInstance.dismiss();
  }

}


UsersNewModalInstanceCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils', '$modalInstance', 'resolved'];
UsersNewModalInstanceCtrl.prototype = Object.create(UsersNewCtrl.prototype);
circaControllers.controller('UsersNewModalInstanceCtrl', UsersNewModalInstanceCtrl);


UsersNewModalInstanceCtrl.prototype.attributesFromLdap = function(scope) {
  console.log('attributesFromLdap');
  console.log(scope.newUser['user']['findUid']);
  var _this = this;
  var uid = scope.newUser['user']['findUid'].trim();
  uid = encodeURIComponent(uid);
  console.log(uid);
  if (uid) {
    var path = "/users/attributes_from_ldap";
    var conf = { params: { uid: uid } }
    this.apiRequests.get(path, conf).then(function(response) {
      if (response.status == 200) {
        scope['findUid'] = '';
        _this.commonUtils.objectMerge(scope.newUser['user'], response.data['user']);
      }
      else if (response.data['error'] && response.data['error']['detail']) {
        scope.flash = response.data['error']['detail'];
      }
    });
  }
}
