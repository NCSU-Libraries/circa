// UsersEditCtrl - inherits from UsersCtrl

var UsersEditCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  UsersCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);
  var _this = this;

  // For edit views, load record after cache is loaded to ensure that controlled/enumerable values are ready
  var processCache = function(cache) {
    _this.processCache(cache, $scope);
    _this.getUser($scope, $routeParams.userId);
  }

  var cache = sessionCache.init(processCache);

  $scope.updateUser = function() {
    _this.updateUser($scope);
  }

  $scope.mode = 'edit';
}

UsersEditCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
UsersEditCtrl.prototype = Object.create(UsersCtrl.prototype);
circaControllers.controller('UsersEditCtrl', UsersEditCtrl);


UsersEditCtrl.prototype.updateUser = function(scope) {
  var _this = this;

  console.log('update');

  if (_this.validateUser(scope)) {
    _this.apiRequests.put("/users/" + scope.user['id'], { 'user': scope.user, 'user_type': 'patron' }).then(function(response) {
      if (response.status == 200) {
        console.log(response.data);
        scope.user = response.data['user'];
        _this.goto('/users/' + scope.user['id']);
      }
      else if (response.data['error'] && response.data['error']['detail']) {
        scope.flash = response.data['error']['detail'];
      }
    });
  }
  else {
    // alert
  }

}
