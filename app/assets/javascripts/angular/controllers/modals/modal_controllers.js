var CircaModalInstanceCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils, $modalInstance, resolved) {
  CircaCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);
  $scope.resolved = resolved;

  console.log(resolved);

  commonUtils.objectMerge($scope, resolved);

  $scope.ok = function (data) {
    $modalInstance.close(data);
  };

  $scope.dismiss = function () {
    $modalInstance.dismiss();
  };
}

CircaModalInstanceCtrl.prototype = Object.create(CircaCtrl.prototype);
CircaModalInstanceCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils', '$modalInstance', 'resolved'];
circaControllers.controller('CircaModalInstanceCtrl', CircaModalInstanceCtrl);
