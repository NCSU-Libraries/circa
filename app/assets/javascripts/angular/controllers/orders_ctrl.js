var OrdersCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {

  $scope.section = 'orders';

  CircaCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  this.initializeFilterConfig($scope);

  // this.applyFunctionsToScope($scope);
}

OrdersCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];

OrdersCtrl.prototype = Object.create(CircaCtrl.prototype);

OrdersCtrl.prototype.applyFunctionsToScope = function(scope) {

  var _this = this;

  // scope.checkOutAvailable = function() {
  //   _this.checkOutAvailable(scope);
  // }

  scope.setDateFilter = function() {
    _this.setDateFilter(scope);
  }

  scope.triggerEvent = function(event) {
    _this.triggerEvent(scope, event);
    _this.setStatesEvents(scope);
  }

  scope.getOrder = function(page, sort) {
    _this.getOrder(scope, page, sort);
  }

  scope.addNote = function() {
    _this.addNote(scope.order);
  }

  scope.removeNote = function(index) {
    _this.removeNote(scope, scope.order, index);
  }

  scope.restoreNote = function(note) {
    _this.restoreNote($scope, scope.order, note);
  }

  scope.createOrder = function() {
    _this.createOrder(scope);
  }

  this.applyArchivesSpaceFunctions(scope);

  this.applyCatalogFunctions(scope);

  this.applyOrderUserFunctions(scope);

  this.applyOrderItemFunctions(scope);

  this.applyDigitalImageFunctions(scope);

  this.applyOrderValidationFunctions(scope);

  this.applyOrderFormUtilityFunctions(scope);

  this.initializeOrderFormComponents(scope);

  this.applyReproductionFunctions(scope);

}


OrdersCtrl.prototype.initializeOrderFormComponents = function(scope) {
  this.initializeArchivesSpaceRecordSelect(scope);
  this.initializeCatalogRecordSelect(scope);
  this.initializeDigitalImageSelect(scope);
  scope.userSelect = this.initializeUserSelect();
  scope.assigneeSelect = this.initializeUserSelect();
  scope.removedUsers = [];
  scope.removedAssignees = [];
  scope.removedItems = [];
  scope.removedItemOrders = [];
  scope.removedDigitalImageOrders = [];
  scope.validationErrors = {};
  scope.hasValidationErrors = false;
}


OrdersCtrl.prototype.getPage = function(scope, page) {
  this.getOrders(scope, page);
}


OrdersCtrl.prototype.getOrders = function(scope, page) {
  var _this = this;

  scope.loading = true;
  var path = '/orders';
  page = page ? page : 1;
  scope.page = page;

  var config = this.listRequestConfig(scope);
  this.updateLocationQueryParams(config['params']);

  this.apiRequests.getPage(path,page,config).then(function(response) {
    scope.loading = false;
    if (response.status == 200) {

      // _this.paramsToQueryString(config['params']);
      // _this.location.search('page', page);

      scope.orders = response.data['orders'];
      var paginationParams = _this.commonUtils.paginationParams(response.data['meta']['pagination']);
      _this.commonUtils.objectMerge(scope, paginationParams);
      _this.setAppliedFilters(scope);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
}


OrdersCtrl.prototype.createOrder = function(scope) {
  var _this = this;

  console.log('create');

  if (scope.order['default_location']) {
    scope.order['temporary_location'] = scope.defaultLocation;
  }

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


// Initialize a new order object
OrdersCtrl.prototype.initializeOrder = function() {
  return {
    users: [],
    items: [],
    archivesspace_records: [],
    notes: [],
    assignees: [],
    default_location: true,
    catalog_records: [],
    catalog_items: [],
    item_orders: [],
    digital_image_orders: []
  };
}


OrdersCtrl.prototype.newOrder = function(scope) {
  scope.order = this.initializeOrder();
  // scope.order['order_type_id'] = this.orderTypeId('research');
  scope.order['temporary_location'] = scope.defaultLocation;
  scope.itemIds = [];
  scope.userEmails = [];
  scope.assigneeEmails = [];
}
