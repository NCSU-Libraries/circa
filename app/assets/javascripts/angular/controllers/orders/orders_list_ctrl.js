// OrdersListCtrl - For list view, inherits from OrdersCtrl

var OrdersListCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  OrdersCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  this.processListParams();
  this.getOrders(this.page);
  this.researchersLimit = 5;
  this.resourcesLimit = 5;
  this.deletedRecordFlash('order');
}

OrdersListCtrl.prototype = Object.create(OrdersCtrl.prototype);

OrdersListCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];

circaControllers.controller('OrdersListCtrl', OrdersListCtrl);


OrdersListCtrl.prototype.resetOrderSubTypeFilter = function() {
  delete this.filterConfig.filters['order_sub_type_id'];
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
