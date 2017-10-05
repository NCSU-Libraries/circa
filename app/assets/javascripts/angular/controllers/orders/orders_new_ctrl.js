// OrdersNewCtrl - For new view, inherits from OrdersCtrl

var OrdersNewCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  OrdersCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  var _this = this;

  $scope.mode = 'new';

  this.newOrder($scope);



  if ($routeParams.userId) {
    var addUserToNewOrder = function(scope) {
      scope.order['users'].push(scope.user);
    }
    this.getUser($scope, $routeParams.userId, addUserToNewOrder);
  }

  this.applyFunctionsToScope($scope);

}

OrdersNewCtrl.prototype = Object.create(OrdersCtrl.prototype);
OrdersNewCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('OrdersNewCtrl', OrdersNewCtrl);


OrdersNewCtrl.prototype.createOrder = function(scope) {
  var _this = this;

  console.log('create');

  // if (scope.order['default_location']) {
  //   scope.order['temporary_location'] = scope.defaultLocation;
  // }

  if (_this.validateOrder(scope)) {
    scope.loading = true;
    _this.apiRequests.post("orders", { 'order': scope.order }).then(function(response) {
      if (response.status == 200) {
        scope.order = response.data['order'];
        _this.goto('/orders/' + scope.order['id']);
        scope.loading = false;
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
