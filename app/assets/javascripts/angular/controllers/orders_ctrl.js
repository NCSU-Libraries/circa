var OrdersCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {

  var _this = this;

  $scope.section = 'orders';

  CircaCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  $scope.setPrimaryUserId = function(userId) {
    _this.setPrimaryUserId($scope, userId);
  }

  // $scope.checkOutAvailable = function() {
  //   _this.checkOutAvailable($scope);
  // }

  $scope.setDateFilter = function() {
    _this.setDateFilter($scope);
  }

  this.initializeFilterConfig($scope);

}


OrdersCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];


OrdersCtrl.prototype = Object.create(CircaCtrl.prototype);


OrdersCtrl.prototype.setPrimaryUserId = function(scope, userId) {
  scope.order['primary_user_id'] = userId;
}


OrdersCtrl.prototype.setDefaultPrimaryUserId = function(scope) {
  if (!scope.order['primary_user_id'] && scope.order['users']) {
    if (scope.order['users'][0]) {
      scope.order['primary_user_id'] = scope.order['users'][0]['id'];
    }
  }
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


OrdersCtrl.prototype.setAppliedFilters = function(scope) {
  scope.filterConfig.appliedFilters = {};
  var filters = scope.filterConfig.filters;
  var skipFilters = ['access_date_start', 'access_date_end'];
  for (var f in filters) {
    if (skipFilters.indexOf(f) < 0) {
      scope.filterConfig.appliedFilters[f] = filters[f];
    }
  }
  // deal with dates
  var fromDate = scope.filterConfig.options['access_date_from'];
  var toDate = scope.filterConfig.options['access_date_to'];
  var dateValue = null;
  if (fromDate && toDate) {
    dateValue = 'between ' + fromDate + ' and ' + toDate;
  }
  else if (fromDate) {
    dateValue = 'after ' + fromDate;
  }
  else if (toDate) {
    dateValue = 'before ' + toDate;
  }
  if (dateValue) {
    scope.filterConfig.appliedFilters['access_dates'] = dateValue;
  }
  scope.filterConfig.filtersApplied = Object.keys(scope.filterConfig.appliedFilters).length > 0 ? true : false;
}


OrdersCtrl.prototype.setDateFilter = function(scope, field) {

  var fromDate = scope.filterConfig.options['access_date_from'];
  var toDate = scope.filterConfig.options['access_date_to'];

  // Handle empty strings
  if (fromDate && fromDate.length == 0) {
    fromDate = null;
    scope.filterConfig.options['access_date_from'] = null;
  }
  if (toDate && toDate.length == 0) {
    toDate = null;
    scope.filterConfig.options['access_date_to'] = null;
  }

  if (fromDate && toDate) {
    var rangeValue =  '[' + fromDate + ' TO ' + toDate + ']';
    scope.filterConfig.filters['access_date_start'] = rangeValue;
    scope.filterConfig.filters['access_date_end'] = rangeValue;
  }
  else if (fromDate && !toDate) {
    var rangeValue =  '[' + fromDate + ' TO *]';
    scope.filterConfig.filters['access_date_start'] = rangeValue;
    delete scope.filterConfig.filters['access_date_end'];
  }
  else if (!fromDate && toDate) {
    var rangeValue =  '[* TO ' + toDate + ']';
    scope.filterConfig.filters['access_date_end'] = rangeValue;
    delete scope.filterConfig.filters['access_date_start'];
  }
  else {
    delete scope.filterConfig.filters['access_date_start'];
    delete scope.filterConfig.filters['access_date_end'];
  }
}



// OrderCtrl - For single-record views, inherits from OrdersCtrl

var OrderCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  OrdersCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);
  var _this = this;

  $scope.triggerEvent = function(event) {
    _this.triggerEvent($scope, event);
    _this.setStatesEvents($scope);
  }

  $scope.getOrder = function(page, sort) {
    _this.getOrder($scope, page, sort);
  }

  $scope.validateOrder = function() {
    _this.validateOrder($scope);
  }

  $scope.hasValidationErrors = function() {
    _this.hasValidationErrors($scope);
  }


  $scope.addNote = function() {
    _this.addNote($scope, $scope.order);
  }

  $scope.removeNote = function(index) {
    _this.removeNote($scope, $scope.order, index);
  }

  $scope.restoreNote = function(note) {
    _this.restoreNote($scope, $scope.order, note);
  }

  $scope.orderTypeIdMatch = function(typeId) {
    _this.orderTypeIdMatch($scope, typeId);
  }

  $scope.availableStateEvents = function(item) {
    return _this.availableStateEvents($scope, item);
  }

  $scope.dateSingleOrRange = function() {
    return _this.dateSingleOrRange($scope);
  }

  $scope.setOrderType = function(orderTypes) {
    _this.setOrderType($scope, orderTypes);
  }

  $scope.setOrderSubType = function(orderSubTypes) {
    _this.setOrderSubType($scope, orderSubTypes);
  }

  // $scope.checkOutAvailable = function() {
  //   _this.checkOutAvailable($scope);
  // }

  this.applyArchivesSpaceFunctions($scope);

  this.applyCatalogFunctions($scope);

  this.applyUserFunctions($scope);

  this.applyItemFunctions($scope);

  this.applyDigitalImageFunctions($scope);

  this.initializeArchivesSpaceRecordSelect($scope);
  this.initializeCatalogRecordSelect($scope);
  this.initializeDigitalImageSelect($scope);
  $scope.userSelect = this.initializeUserSelect();
  $scope.assigneeSelect = this.initializeUserSelect();

  $scope.removedUsers = [];
  $scope.removedAssignees = [];
  $scope.removedItems = [];
  $scope.removedItemOrders = [];
  $scope.removedDigitalImageOrders = [];
  $scope.validationErrors = {};
  $scope.hasValidationErrors = false;

}


OrderCtrl.prototype = Object.create(OrdersCtrl.prototype);


OrderCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];


OrderCtrl.prototype.availableStateEvents = function(scope, item) {
  var available = [];
  function verifyStateEvent(stateEvent, index) {

    var availableEvents = item.available_events_per_order[scope.order.id];

    if (availableEvents && availableEvents.indexOf(stateEvent['event']) >= 0) {
      available.push(stateEvent);
    }
  }

  item['statesEvents'].forEach(verifyStateEvent);
  return available;
}


// Initialize a new order object
OrderCtrl.prototype.initializeOrder = function() {
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
    item_orders: [],
    digital_image_orders: []
  };
}


OrderCtrl.prototype.newOrder = function(scope) {
  scope.order = this.initializeOrder();
  // scope.order['order_type_id'] = this.orderTypeId('research');
  scope.order['temporary_location'] = scope.defaultLocation;
  scope.itemIds = [];
  scope.userEmails = [];
  scope.assigneeEmails = [];
}


OrderCtrl.prototype.validateOrder = function(scope) {
  var valid = true;
  scope.validationErrors = {};
  scope.hasValidationErrors = false;

  if (!scope.order['order_type_id']) {
    scope.validationErrors['order_type_id'] = "Order type must be selected";
  }
  if (!scope.order['order_sub_type_id']) {
    scope.validationErrors['order_sub_type_id'] = "Order type must be selected";
  }

  if (scope.order['item_orders'].length == 0 && scope.order['digital_image_orders'].length == 0) {
    scope.validationErrors['item_orders'] = "Order must include at least one item.";
  }

  if (!scope.order['access_date_start']) {
    scope.validationErrors['access_date'] = "A date must be provided.";
  }

  // if (scope.order['order_type'] && (scope.order['order_type']['name'] != 'research') && !scope.order['access_date_end']) {
  //   scope.validationErrors['access_date'] = "End is date required.";
  // }

  if (scope.order['users'].length == 0 && scope.order['assignees'].length == 0) {
    scope.validationErrors['users'] = "Order must be associated with a user, assigned to a staff member, or both.";
    scope.validationErrors['assignees'] = "Order must be associated with a user, assigned to a staff member, or both.";
  }

  if (Object.keys(scope.validationErrors).length > 0) {
    valid = false;
    scope.hasValidationErrors = true;
  }

  console.log(scope.validationErrors);

  return valid;
}


OrderCtrl.prototype.hasValidationErrors = function(scope) {
  var errors = Object.keys(scope.validationErrors).length;
  console.log(errors + " errors");
  if (errors > 0) {
    return true;
  }
  else {
    return false;
  }
}


OrderCtrl.prototype.orderTypeIdMatch = function(scope, typeId) {
  if (scope.order['order_type_id'] == typeId) {
    return true;
  }
  else {
    return false;
  }
}



// // SAFE COPY BEFORE REMOVING items FROM order
// OrderCtrl.prototype.removeItem = function(scope, item, callback) {
//   var _this = this;

//   var removeItemIndex = scope.order['item_orders'].findIndex(function(item_order, index, array) {
//     return item_order['item']['id'] == item['id'];
//   });

//   if (removeItemIndex >= 0) {
//     var removeItem = scope.order['items'].splice(removeItemIndex, 1)[0];
//     scope.removedItems.push(removeItem);
//     scope.itemIds.splice( scope.itemIds.indexOf(removeItem['id']), 1);
//     _this.removeFromItemOrders(scope, removeItem['id']);
//     _this.commonUtils.executeCallback(callback, scope);
//     return true;
//   }
// }


// // SAFE COPY BEFORE REMOVING items FROM order
// OrderCtrl.prototype.restoreItem = function(scope, item, callback) {
//   var _this = this;
//   var restoreItemIndex = scope.removedItems.findIndex(function(element, index, array) {
//     return element['id'] == item['id'];
//   });
//   if (restoreItemIndex >= 0) {
//     var restoreItem = scope.removedItems.splice(restoreItemIndex, 1);
//     restoreItem = restoreItem[0];
//     scope.order['items'].push(restoreItem);
//     scope.itemIds.push(item['id'])
//     _this.restoreItemOrder(scope, item['id']);
//     _this.commonUtils.executeCallback(callback, scope);
//     return true;
//   }
// }


OrderCtrl.prototype.setOrderType = function(scope, orderTypes) {
  var value = this.getControlledValue(orderTypes, scope.order['order_type_id']);
  scope.order['order_type'] = value;
  scope.dateSingleOrRange = this.dateSingleOrRange(scope);
  scope.userLabel = this.userLabel(scope);
}


OrderCtrl.prototype.setOrderSubType = function(scope, orderSubTypes) {
  var value = this.getControlledValue(orderSubTypes, scope.order['order_sub_type_id']);
  scope.order['order_sub_type'] = value;
  scope.dateSingleOrRange = this.dateSingleOrRange(scope);
}


OrderCtrl.prototype.dateSingleOrRange = function(scope) {
  var val = 'range';

  if (scope.order['order_type'] && scope.order['order_sub_type']) {
    if (scope.order['order_type']['name'] == 'research' && scope.order['order_sub_type']['name'] != 'course_reserve') {
      val = 'single';
    }
    else if (scope.order['order_type']['name'] == 'reproduction') {
      val = 'single';
    }
  }

  return val;
}

