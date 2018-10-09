var OrdersCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  this.section = 'orders';

  CircaCtrl.call(this, $route, $routeParams, $location, $window,
      apiRequests, sessionCache, commonUtils, formUtils);

  this.initializeFilterConfig();

  // this.applyFunctionsToScope($scope);
}

OrdersCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];

OrdersCtrl.prototype = Object.create(CircaCtrl.prototype);

circaControllers.controller('OrdersCtrl', OrdersCtrl);


// registering this here but it should be redefined in angular/controllers/custom if needed
OrdersCtrl.prototype.initializeCustomFormComponents = function() {
}


OrdersCtrl.prototype.initializeOrderFormComponents = function() {
  this.initializeArchivesSpaceRecordSelect();
  this.showItemSelector = false;
  this.userSelect = this.initializeUserSelect();
  this.assigneeSelect = this.initializeUserSelect();
  this.removedUsers = [];
  this.removedAssignees = [];
  this.removedItems = [];
  this.removedItemOrders = [];
  this.removedDigitalCollectionsOrders = [];
  this.validationErrors = {};
  this.hasValidationErrors = false;
  this.itemIds = [];
  this.userEmails = [];
  this.assigneeEmails = [];
  this.initializeCustomFormComponents();
}


OrdersCtrl.prototype.getPage = function(page) {
  this.getOrders(page);
}


OrdersCtrl.prototype.getOrders = function(page) {
  var _this = this;

  this.loading = true;
  var path = '/orders';
  page = page ? page : 1;
  this.page = page;

  var config = this.listRequestConfig();
  this.updateLocationQueryParams(config['params']);

  this.apiRequests.getPage(path,page,config).then(function(response) {
    _this.loading = false;
    if (response.status == 200) {

      // _this.paramsToQueryString(config['params']);
      // _this.location.search('page', page);

      _this.orders = response.data['orders'];
      var paginationParams = _this.commonUtils.paginationParams(response.data['meta']['pagination']);
      _this.commonUtils.objectMerge(_this, paginationParams);
      _this.setAppliedFilters();
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.flash = response.data['error']['detail'];
    }
  });
}


OrdersCtrl.prototype.createOrder = function() {
  var _this = this;

  if (this.validateOrder()) {
    this.loading = true;
    this.apiRequests.post("orders", { 'order': _this.order }).then(function(response) {
      if (response.status == 200) {
        _this.order = response.data['order'];
        _this.goto('/orders/' + _this.order['id']);
        _this.loading = false;
      }
      else if (response.data['error'] && response.data['error']['detail']) {
        _this.flash = response.data['error']['detail'];
      }
    });
  }
  else {
    this.window.scroll(0,0);
  }
}


OrdersCtrl.prototype.cloneOrder = function(id, callback) {
  var path = '/orders/' + id;
  var _this = this;
  var preserveKeys = Object.keys(this.initializeOrder());

  this.loading = true;

  this.apiRequests.get(path).then(function(response) {
    if (response.status == 200) {
      var order = response.data['order'];

      var deleteKeys = ['id', 'access_date_start', 'access_date_end',
          'confirmed', 'open', 'created_at', 'updated_at', 'current_state',
          'permitted_events', 'available_events', 'states_events',
          'created_by_user', 'assignees'];

      order['users'] = order['users'].filter(function(user) {
        return user['id'] == order['primary_user_id'];
      });

      order['cloned_order_id'] = id;

      for (var i = 0; i < deleteKeys.length; i++) {
        delete order[deleteKeys[i]];
      }

      _this.loading = false;
      _this.refreshOrder(order, callback);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.errorCode = response.status;
      _this.flash = response.data['error']['detail'];
    }
  });
}


// Initialize a new order object
OrdersCtrl.prototype.initializeOrder = function() {
  return {
    users: [],
    items: [],
    archivesspace_records: [],
    notes: [],
    assignees: [],
    catalog_records: [],
    catalog_items: [],
    item_orders: [],
    digital_collections_orders: []
  };
}


OrdersCtrl.prototype.newOrder = function() {
  this.order = this.initializeOrder();
}


OrdersCtrl.prototype.customTemplate = function(templateName) {
  var template;
  if (typeof this.customTemplates !== 'undefined') {
    template = this.customTemplates(templateName);
  }
  return (typeof template !== 'undefined') ? template : null;
}
