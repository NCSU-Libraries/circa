// Enumeration values

var OrderSubTypesCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {

  var _this = this;

  SettingsCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  $scope.updateOrderSubType = function() {
    _this.updateOrderSubType($scope);
  }

  $scope.createOrderSubType = function() {
    _this.createOrderSubType($scope);
  }

  // $scope.mergeOrderSubTypes = function() {
  //   _this.mergeorderSubTypes($scope);
  // }

}

OrderSubTypesCtrl.prototype = Object.create(SettingsCtrl.prototype);
OrderSubTypesCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('OrderSubTypesCtrl', OrderSubTypesCtrl);


OrderSubTypesCtrl.prototype.getOrderSubTypes = function(scope, callback) {
  scope.loading = true;
  var _this = this;
  var path = '/order_sub_types';
  this.apiRequests.get(path).then(function(response) {
    scope.loading = false;
    if (response.status == 200) {
      // NOTE: scope.enumerationValues is set on every page when the cache is set - don't use that one
      scope.orderSubTypes = response.data['order_sub_types'];
      _this.commonUtils.executeCallback(callback, scope);
    }
    else {
      scope.error = response.data['error'];
    }
  });
}

OrderSubTypesCtrl.prototype.getOrderSubType = function(scope, id, callback) {
  scope.loading = true;
  var _this = this;
  var path = '/order_sub_types/' + id;
  this.apiRequests.get(path).then(function(response) {
    scope.loading = false;
    if (response.status == 200) {
      scope.orderSubType = response.data['order_sub_type'];
      scope.orderType = response.data['order_sub_type']['order_type'];
      _this.commonUtils.executeCallback(callback, scope);
    }
    else {
      scope.error = response.data['error'];
    }
  });
}


OrderSubTypesCtrl.prototype.updateOrderSubType = function(scope, callback) {
  scope.loading = true;
  var _this = this;
  var path = '/order_sub_types/' + scope.orderSubType.id;
  this.apiRequests.put(path, { order_sub_type: scope.orderSubType }).then(function(response) {
    scope.loading = false;
    if (response.status == 200) {
      _this.goto('/settings/order_sub_types');
    }
    else {
      scope.error = response.data['error'];
    }
  });
}
