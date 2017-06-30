// OrdersListCtrl - For list view, inherits from OrdersCtrl

var OrdersListCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {

  var _this = this;

  OrdersCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  // $scope.getOrders = function(page, sort) {
  //   this.getOrders($scope, page, sort);
  // }

  this.processListParams($scope);




  this.getOrders($scope, $scope.page);


  $scope.researchersLimit = 5;
  $scope.resourcesLimit = 5;

  $scope.resetOrderSubTypeFilter = function() {
    _this.resetOrderSubTypeFilter($scope);
  }

  $scope.getControlledValueLabel = function(values, id) {
    return _this.getControlledValueLabel(values, id);
  }

}


OrdersListCtrl.prototype = Object.create(OrdersCtrl.prototype);

OrdersListCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];

circaControllers.controller('OrdersListCtrl', OrdersListCtrl);


OrdersListCtrl.prototype.resetOrderSubTypeFilter = function(scope) {
  delete scope.filterConfig.filters['order_sub_type_id'];
}


OrdersListCtrl.prototype.getControlledValueLabel = function(values, id) {
  var label;
  if (values) {
    for (var i = 0; i < values.length; i++) {
      var value = values[i];
      if (value.id == id) {
        label = value.label;
        break;
      }
    }
  }
  return label;
}
