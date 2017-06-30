var ItemCheckoutModalInstanceCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils, $modalInstance, resolved) {

  var _this = this;

  console.log($scope);

  CircaModalInstanceCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils, $modalInstance, resolved);

  // commonUtils.objectMerge($scope, resolved);

  $scope.ok = function (data) {
    console.log('THIS IS ItemCheckoutModalInstanceCtrl!');
    $.each($scope.items, function(index, item) {
      _this.checkOutItem($scope, item['id'], $scope.checkOutUsers);
    });

    $modalInstance.close();
  };

  $scope.dismiss = function () {
    $modalInstance.dismiss();
  };
}

ItemCheckoutModalInstanceCtrl.prototype = Object.create(CircaModalInstanceCtrl.prototype);
ItemCheckoutModalInstanceCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils', '$modalInstance', 'resolved'];
circaControllers.controller('ItemCheckoutModalInstanceCtrl ', ItemCheckoutModalInstanceCtrl );
