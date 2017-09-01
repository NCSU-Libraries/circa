// OrdersShowCtrl - For show view, inherits from OrdersCtrl

var OrdersShowCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  OrdersCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  var _this = this;

  var callback = function(scope) {
    _this.setStatesEvents(scope);
    _this.initializeCheckOut(scope);
    _this.setDefaultPrimaryUserId(scope);
  }

  this.getOrder($scope, $routeParams.orderId, callback);

  $scope.getOrderHistory = function() {
    _this.getOrderHistory($scope);
  }

  $scope.usersLimit = 5;
  $scope.itemsLimit = 10;
  $scope.truncateUsers = true;
  $scope.truncateItems = true;

  $scope.calculatedUsersLimit = function() {
    return $scope.truncateUsers ? $scope.usersLimit : $scope.order.users.length
  }

  $scope.calculatedItemsLimit = function() {
    return $scope.truncateItems ? $scope.itemsLimit : $scope.order.items.length
  }

  $scope.toggleTruncateUsers = function() {
    _this.toggleTruncateUsers($scope);
  }

  $scope.toggleTruncateItems = function() {
    _this.toggleTruncateItems($scope);
  }

}


OrdersShowCtrl.prototype = Object.create(OrdersCtrl.prototype);
OrdersShowCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('OrdersShowCtrl', OrdersShowCtrl);


OrdersShowCtrl.prototype.getOrderHistory = function(scope) {
  var path = '/orders/' + scope['order']['id'] + '/history';
  var _this = this;
  this.apiRequests.get(path).then(function(response) {
    if (response.status == 200) {
      scope['order']['history'] = response.data['order']['history'];
    }
    else {
      scope.error = response.data['error'];
    }
  });
}


OrdersShowCtrl.prototype.toggleTruncateUsers = function(scope) {
  scope.truncateUsers = (scope.truncateUsers == false) ? true : false;
}


OrdersShowCtrl.prototype.toggleTruncateItems = function(scope) {
  scope.truncateItems = (scope.truncateItems == false) ? true : false;
}
