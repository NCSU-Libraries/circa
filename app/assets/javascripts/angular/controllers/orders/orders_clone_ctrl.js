// OrdersCloneCtrl - For clone/new view, inherits from OrdersCtrl

var OrdersCloneCtrl = function($scope, $route, $routeParams, $location, $window,
    $modal, apiRequests, sessionCache, commonUtils, formUtils) {

  OrdersCtrl.call(this, $scope, $route, $routeParams, $location, $window,
    $modal, apiRequests, sessionCache, commonUtils, formUtils);

  var _this = this;

  $scope.mode = 'new';

  var callback = function(scope) {
    _this.setDefaultPrimaryUserId(scope);
    _this.applyFunctionsToScope(scope);
    scope.dateSingleOrRange = _this.dateSingleOrRange(scope);
    // if (!scope.order['temporary_location']) {
    //   scope.order['temporary_location'] = scope.defaultLocation;
    //   scope.order['default_location'] = true;
    // }
  }

  // For clone/edit views, load record after cache is loaded to ensure that
  //   controlled/enumerable values are ready
  $scope.processCache = function(cache) {
    _this.processCache(cache, $scope);
    _this.cloneOrder($scope, $routeParams.orderId, callback);
  }

  if ($routeParams.orderId) {
    var cache = sessionCache.init($scope.processCache);
    $scope.clonedFromOrderId = $routeParams.orderId;
  }
  else {
    this.goto('orders/new');
  }

}

OrdersCloneCtrl.prototype = Object.create(OrdersCtrl.prototype);
OrdersCloneCtrl.$inject = ['$scope', '$route', '$routeParams', '$location',
  '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils',
  'formUtils'];
circaControllers.controller('OrdersCloneCtrl', OrdersCloneCtrl);



OrdersCloneCtrl.prototype.cloneOrder = function(scope, id, callback) {
  var path = '/orders/' + id;
  var _this = this;
  var preserveKeys = Object.keys(this.initializeOrder());

  scope.loading = true;
  this.apiRequests.get(path).then(function(response) {
    if (response.status == 200) {
      var order = response.data['order'];

      var deleteKeys = ['id', 'access_date_start', 'access_date_end',
        'confirmed', 'open', 'created_at', 'updated_at', 'current_state',
        'permitted_events', 'available_events', 'states_events',
        'created_by_user', 'assignees'];

      order['cloned_order_id'] = id;

      for (var i = 0; i < deleteKeys.length; i++) {
        delete order[deleteKeys[i]];
      }

      scope.loading = false;
      _this.refreshOrder(scope, order, callback)
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.errorCode = response.status;
      scope.flash = response.data['error']['detail'];
    }
  });
}
