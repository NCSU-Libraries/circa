var SelectNewActiveOrderModalInstanceCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils, $modalInstance, resolved) {

  var _this = this;

  // this.item = resolved['item'];
  $scope.item = resolved['item'];
  $scope.item['selectedOrderId'] = $scope.item.active_order_id

  $scope.changeSelectedOrderId = function(orderId) {
    this.changeSelectedOrderId($scope, orderId);
  }

  CircaModalInstanceCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils, $modalInstance, resolved);

  // commonUtils.objectMerge($scope, resolved);

  $scope.ok = function (data) {
    $modalInstance.close($scope.item['selectedOrderId']);
  };

  $scope.dismiss = function () {
    $modalInstance.dismiss();
  };
}

SelectNewActiveOrderModalInstanceCtrl.prototype = Object.create(CircaModalInstanceCtrl.prototype);
SelectNewActiveOrderModalInstanceCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils', '$modalInstance', 'resolved'];
circaControllers.controller('SelectNewActiveOrderModalInstanceCtrl', SelectNewActiveOrderModalInstanceCtrl );


SelectNewActiveOrderModalInstanceCtrl.prototype.changeSelectedOrderId = function(scope, orderId) {
  console.log('changeSelectedOrderId = ' + orderId);
  scope.item['selectedOrderId'] = orderId;
}
