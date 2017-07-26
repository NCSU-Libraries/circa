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

  // $scope.checkOutAvailable = function() {
  //   _this.checkOutAvailable($scope);
  // }

  $scope.addUser = function(item) {
    _this.addUser($scope, item);
  }

  $scope.addAssignee = function(item) {
    _this.addAssignee($scope, item);
  }

  $scope.addItemsFromArchivesSpace = function() {
    _this.addItemsFromArchivesSpace($scope);
  }

  $scope.addItemFromCatalog = function(catalogRecordId, catalogItemId) {
    _this.addItemFromCatalog(catalogRecordId, catalogItemId, $scope);
  }

  $scope.getCatalogRecord = function() {
    _this.getCatalogRecord($scope);
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

  $scope.validateOrder = function() {
    _this.validateOrder($scope);
  }

  $scope.removeUser = function(user) {
    _this.removeUserOrAssignee($scope, 'users', user);
  }

  $scope.removeAssignee = function(user) {
    _this.removeUserOrAssignee($scope, 'assignees', user);
  }

  $scope.restoreUser = function(user) {
    _this.restoreUserOrAssignee($scope, 'users', user);
  }

  $scope.restoreAssignee = function(user) {
    _this.restoreUserOrAssignee($scope, 'assignees', user);
  }

  $scope.removeItem = function(item) {
    _this.removeItem($scope, item);
  }

  $scope.restoreItem = function(item) {
    _this.restoreItem($scope, item);
  }

  $scope.hasValidationErrors = function() {
    _this.hasValidationErrors($scope);
  }

  $scope.orderTypeIdMatch = function(typeId) {
    _this.orderTypeIdMatch($scope, typeId);
  }

  $scope.createAndAddUser = function() {
    _this.createAndAddUser($scope);
  }

  $scope.createAndAddAssignee = function() {
    _this.createAndAddAssignee($scope);
  }

  $scope.availableStateEvents = function(item) {
    return _this.availableStateEvents($scope, item);
  }

  $scope.deactivateItem = function(item) {
    _this.updateItemActivation($scope, item, 'deactivate');
  }

  $scope.activateItem = function(item) {
    _this.updateItemActivation($scope, item, 'activate');
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

  $scope.archivesSpaceRecordSelect = this.initializeArchivesSpaceRecordSelect();
  $scope.catalogRecordSelect = this.initializeCatalogRecordSelect();
  $scope.userSelect = this.initializeUserSelect();
  $scope.assigneeSelect = this.initializeUserSelect();
  $scope.removedUsers = [];
  $scope.removedAssignees = [];
  $scope.removedItems = [];
  $scope.removedItemOrders = [];
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


// Initialize object used to manage selections from ArchivesSpace
OrderCtrl.prototype.initializeArchivesSpaceRecordSelect = function() {
  return { 'uri': '', 'loading': false, 'alert': null, 'digitalObject': false };
}


// Initialize object used to manage selections from catalog
OrderCtrl.prototype.initializeCatalogRecordSelect = function() {
  return { 'catalogRecordId': '', 'catalogRecordData': '', 'requestItemId': '', 'loading': false, 'alert': null };
}


// Initialize object used to manage user selection
OrderCtrl.prototype.initializeUserSelect = function(scope) {
  return { 'email': '', 'loading': false, 'alert': null };
}


// Initialize a new order object
OrderCtrl.prototype.initializeOrder = function() {
  return { 'users': [], 'items': [], 'archivesspace_records': [], 'notes': [], 'assignees': [], 'default_location': true, 'catalog_records': [], 'catalog_items': [], 'item_orders': [] };
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

  if (scope.order['items'].length == 0) {
    scope.validationErrors['items'] = "Order must include at least one item.";
  }
  if (!scope.order['access_date_start']) {
    scope.validationErrors['access_date'] = "A date must be provided.";
  }

  if (scope.order['order_type'] && (scope.order['order_type']['name'] != 'research') && !scope.order['access_date_end']) {
    scope.validationErrors['access_date'] = "End is date required.";
  }

  if (scope.order['users'].length == 0 && scope.order['assignees'].length == 0) {
    scope.validationErrors['users'] = "Order must be associated with a user, assigned to a staff member, or both.";
    scope.validationErrors['assignees'] = "Order must be associated with a user, assigned to a staff member, or both.";
  }

  if (Object.keys(scope.validationErrors).length > 0) {
    valid = false;
    scope.hasValidationErrors = true;
  }
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


// OrderCtrl.prototype.addNote = function(scope, callback) {
//   if (scope.order['notes'].indexOf('') < 0) {
//     scope.order['notes'].push( { 'content': '' } );
//   }
// }


// OrderCtrl.prototype.removeNote = function(scope, index) {
//   if (scope.order['notes'][index]) {
//     var removed = scope.order['notes'].splice(index,1);
//     removed = removed[0];
//     scope.removedNotes.push(removed);
//   }
// }


// OrderCtrl.prototype.restoreNote = function(scope, note) {
//   console.log(note);
//   var _this = this;
//   var restoreNoteIndex = scope.removedNotes.indexOf(note);
//   if (restoreNoteIndex >= 0) {
//     scope.removedNotes.splice(restoreNoteIndex, 1);
//     scope.order['notes'].push(note);
//   }
//   return true;
// }





OrderCtrl.prototype.addUser = function(scope, item) {
  var _this = this;

  if (item) {

    // var email = scope.userSelect['email'];
    var user = item.originalObject;
    var email = item.originalObject['email'];

    scope.userSelect['loading'] = true;
    scope.userSelect['alert'] = null;

    scope.userSelect = _this.initializeUserSelect();
    scope.$broadcast('angucomplete-alt:clearInput', 'userSelectEmail');

    if (scope.userEmails.indexOf(email) >= 0) {
      // scope.userSelect = _this.initializeUserSelect();
      scope.userSelect['alert'] = 'A user with email ' + email + ' is already associated with this order.';
    }
    else {
      // scope.userSelect = _this.initializeUserSelect();
      scope.order['users'].push(user);
      scope.userEmails.push(email);
      _this.setDefaultPrimaryUserId(scope);
    }
  }
}


OrderCtrl.prototype.openNewUserModal = function(scope) {
  var _this = this;
  _this.window.scroll(0,0);
  return _this.modal.open({
    templateUrl: _this.templateUrl('users/new_modal'),
    controller: 'UsersNewModalInstanceCtrl',
    scope: scope,
    parent: 'main',
    resolve: {
      resolved: function() {
        return {
          user: _this.initializeUser(),
          find_unity_id: ''
        }
      }
    }
  });
}


OrderCtrl.prototype.createAndAddUser = function(scope) {
  var _this = this;

  var scrollY = _this.window.scrollY;

  var modalInstance = _this.openNewUserModal();

  modalInstance.result.then(function (result) {

    console.log(result);

    scope.order['users'].push(result['user']);
    scope.userEmails.push( result['user']['email'] );
    _this.window.scroll(0,scrollY);
  }, function () {
    console.log('Modal dismissed at: ' + new Date());
    _this.window.scroll(0,scrollY);
  });
}


OrderCtrl.prototype.addAssignee = function(scope, item) {
  var _this = this;
  if (item) {
    var assignee = item.originalObject;
    var email = item.originalObject['email'];

    scope.assigneeSelect['loading'] = true;
    scope.assigneeSelect['alert'] = null;

    scope.assigneeSelect = _this.initializeUserSelect();

    if (scope.assigneeEmails.indexOf(email) >= 0) {
      scope.assigneeSelect['alert'] = 'A user with email ' + email + ' is already associated with this order.';
    }
    else {
      scope.order['assignees'].push(assignee);
      scope.assigneeEmails.push(email);
    }
  }
}


OrderCtrl.prototype.createAndAddAssignee = function(scope) {
  var _this = this;

  var scrollY = _this.window.scrollY;

  var modalInstance = _this.openNewUserModal();

  modalInstance.result.then(function (result) {
    scope.order['assignees'].push(result['user']);
    _this.window.scroll(0,scrollY);
  }, function () {
    console.log('Modal dismissed at: ' + new Date());
    _this.window.scroll(0,scrollY);
  });
}


OrderCtrl.prototype.removeUserOrAssignee = function(scope, association, user, callback) {
  var _this = this;

  var removeUserIndex = scope.order[association].findIndex(function(element, index, array) {
    return element['id'] == user['id'];
  });

  if (removeUserIndex >= 0) {
    var removeUser = scope.order[association].splice(removeUserIndex, 1);
    removeUser = removeUser[0];
    if (association == 'users') {
      scope.removedUsers.push(removeUser);
      _this.setDefaultPrimaryUserId(scope);
    }
    else if (association == 'assignees') {
      scope.removedAssignees.push(removeUser);
    }

    _this.commonUtils.executeCallback(callback, scope);

    return true;
  }
}


OrderCtrl.prototype.restoreUserOrAssignee = function(scope, association, user, callback) {
  var _this = this;
  var restoreUserIndex;
  var findIndexCallback = function(element, index, array) {
    return element['id'] == user['id'];
  }

  if (association == 'users') {
    restoreUserIndex = scope.removedUsers.findIndex(findIndexCallback);
  }
  else if (association == 'assignees') {
    restoreUserIndex = scope.removedAssignees.findIndex(findIndexCallback);
  }

  if (restoreUserIndex >= 0) {
    var restoreUser;

    if (association == 'users') {
      restoreUser = scope.removedUsers.splice(restoreUserIndex, 1);
    }
    else if (association == 'assignees') {
      restoreUser = scope.removedAssignees.splice(restoreUserIndex, 1);
    }

    restoreUser = restoreUser[0];
    scope.order[association].push(restoreUser);
    _this.commonUtils.executeCallback(callback, scope);
    return true;
  }
}


// OrderCtrl.prototype.removeUser = function(scope, user, callback) {
//   var _this = this;

//   console.log(user);

//   var removeUserIndex = scope.order['users'].findIndex(function(element, index, array) {
//     return element['id'] == user['id'];
//   });

//   console.log(removeUserIndex);

//   if (removeUserIndex >= 0) {
//     var removeUser = scope.order['users'].splice(removeUserIndex, 1);
//     removeUser = removeUser[0];
//     scope.removedUsers.push(removeUser);
//     _this.setDefaultPrimaryUserId(scope);
//     _this.commonUtils.executeCallback(callback, scope);

//     console.log(scope.removedUsers);

//     return true;
//   }
// }


OrderCtrl.prototype.restoreUser = function(scope, user, callback) {
  var _this = this;
  var restoreUserIndex = scope.removedUsers.findIndex(function(element, index, array) {
    return element['id'] == user['id'];
  });
  if (restoreUserIndex >= 0) {
    var restoreUser = scope.removedUsers.splice(restoreUserIndex, 1);
    restoreUser = restoreUser[0];
    scope.order['users'].push(restoreUser);
    _this.commonUtils.executeCallback(callback, scope);
    return true;
  }
}


OrderCtrl.prototype.getItemOrderIndex = function(itemOrders, itemId) {
  return itemOrders.findIndex(function(element, index, array) {
    return element['item_id'] == itemId;
  });
}


OrderCtrl.prototype.addItemOrder = function(scope, itemId, archivesspace_uri) {
  archivesspace_uri = archivesspace_uri ? [ archivesspace_uri ] : null;
  scope.order['item_orders'].push( { order_id: scope.order['id'], item_id: itemId, archivesspace_uri: archivesspace_uri } );
}


OrderCtrl.prototype.removeFromItemOrders = function(scope, itemId) {
  var targetIndex = this.getItemOrderIndex(scope.order['item_orders'], itemId);
  var itemOrder = scope.order['item_orders'].splice(targetIndex, 1)[0];
  scope.removedItemOrders.push(itemOrder);
}


OrderCtrl.prototype.restoreItemOrder = function(scope, itemId) {
  var targetIndex = this.getItemOrderIndex(scope.removedItemOrders, itemId);
  var itemOrder = scope.removedItemOrders.splice(targetIndex, 1)[0];
  scope.order['item_orders'].push(itemOrder);
}


OrderCtrl.prototype.removeItem = function(scope, item, callback) {
  var _this = this;

  var removeItemIndex = scope.order['items'].findIndex(function(element, index, array) {
    return element['id'] == item['id'];
  });

  if (removeItemIndex >= 0) {
    var removeItem = scope.order['items'].splice(removeItemIndex, 1)[0];
    scope.removedItems.push(removeItem);
    scope.itemIds.splice( scope.itemIds.indexOf(removeItem['id']), 1);
    _this.removeFromItemOrders(scope, removeItem['id']);
    _this.commonUtils.executeCallback(callback, scope);
    return true;
  }
}


OrderCtrl.prototype.restoreItem = function(scope, item, callback) {
  var _this = this;
  var restoreItemIndex = scope.removedItems.findIndex(function(element, index, array) {
    return element['id'] == item['id'];
  });
  if (restoreItemIndex >= 0) {
    var restoreItem = scope.removedItems.splice(restoreItemIndex, 1);
    restoreItem = restoreItem[0];
    scope.order['items'].push(restoreItem);
    scope.itemIds.push(item['id'])
    _this.restoreItemOrder(scope, item['id']);
    _this.commonUtils.executeCallback(callback, scope);
    return true;
  }
}


OrderCtrl.prototype.orderArchivesSpaceRecords = function (scope) {
  var records = [];
  if ((scope.order) && scope.order['item_orders']) {
    scope.order['item_orders'].forEach(function(orderItem) {
      records = records.concat(orderItem['archivesspace_uri']);
    });
  }
  return records;
}


OrderCtrl.prototype.addItemsFromArchivesSpace = function(scope, callback) {
  var _this = this;

  var uri = scope.archivesSpaceRecordSelect['uri'];

  scope.archivesSpaceRecordSelect['loading'] = true;
  scope.archivesSpaceRecordSelect['alert'] = null;

  var addArchivesSpaceUriToItemOrder = function(itemId, uri) {
    var targetIndex = _this.getItemOrderIndex(scope.order['item_orders'], itemId);
    if (targetIndex) {
      scope.order['item_orders'][targetIndex]['archivesspace_uri'].push(uri);
    }
  }


  if (_this.orderArchivesSpaceRecords(scope).indexOf(uri) >= 0) {
    scope.archivesSpaceRecordSelect = _this.initializeArchivesSpaceRecordSelect();
    scope.archivesSpaceRecordSelect['alert'] = 'The ArchivesSpace record at ' + uri + ' is already included in this order.';
  }
  else {
    _this.apiRequests.post('items/create_from_archivesspace', { 'archivesspace_uri': scope.archivesSpaceRecordSelect['uri'], 'digital_object': scope.archivesSpaceRecordSelect['digitalObject'] } ).then(function(response) {

      scope.archivesSpaceRecordSelect['loading'] = false;

      if (response.status == 200) {
        if (Array.isArray(response.data['items'])) {
          $.each(response.data['items'], function(index, item) {
            if (scope.itemIds.indexOf(item['id']) < 0) {
              scope.itemIds.push(item['id']);
              item['archivesspace_uri'] = uri;
              scope.order['items'].push(item);
              _this.addItemOrder(scope, item['id'], scope.archivesSpaceRecordSelect['uri']);
            }
            else {
              scope.archivesSpaceRecordSelect['alert'] = "One or more containers corresponding to the ArchivesSpace record is already included in the order. The ArchivesSpace URI entered will be added for reference.";
              addArchivesSpaceUriToItemOrder(item['id'], scope.archivesSpaceRecordSelect['uri']);
            }
          });
          scope.archivesSpaceRecordSelect['uri'] = null;
          scope.archivesSpaceRecordSelect['digitalObject'] = false;
          _this.commonUtils.executeCallback(callback, response.data);
        }
        else {
          scope.archivesSpaceRecordSelect = _this.initializeArchivesSpaceRecordSelect();
          scope.archivesSpaceRecordSelect['alert'] = 'The ArchivesSpace record at ' + uri + ' has no linked containers and cannot be ordered.';
        }
      }
      else {
        scope.archivesSpaceRecordSelect = _this.initializeArchivesSpaceRecordSelect();
        scope.archivesSpaceRecordSelect['alert'] = response.data['error']['detail'];
      }
    });
  }

}


// 0bject used to manage selections from catalog
// { 'catalogRecordId': '', 'catalogRecordData': null, 'requestItemId': '', 'loading': false, 'alert': null };

OrderCtrl.prototype.getCatalogRecord = function(scope, callback) {
  var _this = this;
  var catalogRecordId = scope.catalogRecordSelect['catalogRecordId'];
  scope.catalogRecordSelect['loading'] = true;
  scope.catalogRecordSelect['alert'] = null;

  _this.apiRequests.get('catalog_get', { 'params': { 'catalog_record_id': catalogRecordId } } ).then(function(response) {
    scope.catalogRecordSelect['loading'] = false;
    if (response.status == 200) {
      scope.catalogRecordSelect['catalogRecordData'] = response.data['data'];
    }
  });
}


OrderCtrl.prototype.addItemFromCatalog = function(catalogRecordId, catalogItemId, scope, callback) {
  var _this = this;

  if (catalogRecordId.match(/\//)) {
    var urlParts = catalogRecordId.split('/');
    catalogRecordId = urlParts[urlParts.length - 1]
  }

  scope.catalogRecordSelect['loading'] = true;
  scope.catalogRecordSelect['alert'] = null;

  // if (scope.order['catalog_records'].indexOf(catalogRecordId) >= 0) {
  //   scope.catalogRecordSelect = _this.initializeCatalogRecordSelect();
  //   scope.catalogRecordSelect['alert'] = 'An item associated with the catalog record with id ' + catalogRecordId + ' is already included in this order.';
  // }

  if (scope.order['catalog_items'].indexOf(catalogItemId) >= 0) {
    scope.catalogRecordSelect = _this.initializeCatalogRecordSelect();
    scope.catalogRecordSelect['alert'] = 'An item associated with item ' + catalogItemId + ' from catalog record with id ' + catalogRecordId + ' is already included in this order.';
  }
  else {
    scope.order['catalog_records'].push(catalogRecordId);
    scope.order['catalog_items'].push(catalogItemId);
    _this.apiRequests.post('items/create_from_catalog', { 'catalog_record_id': catalogRecordId, 'catalog_item_id': catalogItemId } ).then(function(response) {
      scope.catalogRecordSelect['loading'] = false;
      if (response.status == 200) {
        var item = response.data['item'];

        console.log(item);

        if (scope.itemIds.indexOf(item['id']) < 0) {
          scope.itemIds.push(item['id']);
          scope.order['items'].push(item);
          scope.catalogRecordSelect = _this.initializeCatalogRecordSelect();
          _this.addItemOrder(scope, item['id']);
        }
        else {
          scope.catalogRecordSelect['alert'] = 'An item associated with the catalog record with id ' + catalogRecordId + ' is already included in this order.';
        }
      }
      else if (response.status == 500) {
        scope.catalogRecordSelect['alert'] = 'A system error has occurred (500)';
      }
    });
  }
}


OrderCtrl.prototype.updateItemActivation = function(scope, item, method) {
  scope.itemEventLoading = true;
  var _this = this;
  var path = 'orders/' + scope.order.id
  if (method == 'activate') {
    path = path + '/activate_item';
  }
  else if (method == 'deactivate') {
    path = path + '/deactivate_item';
  }
  else {
    scope.flash = 'Invalid method supplied for updateItemAction';
    return
  }

  data = { item_id: item.id };

  this.apiRequests.put(path, data).then(function(response) {
    scope.itemEventLoading = false;
    if (response.status == 200) {
      _this.refreshOrder(scope, response.data['order'])
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
}


OrderCtrl.prototype.setOrderType = function(scope, orderTypes) {
  var value = this.getControlledValue(orderTypes, scope.order['order_type_id']);
  scope.order['order_type'] = value;
  scope.dateSingleOrRange = this.dateSingleOrRange(scope);
}


OrderCtrl.prototype.setOrderSubType = function(scope, orderSubTypes) {
  var value = this.getControlledValue(orderSubTypes, scope.order['order_sub_type_id']);
  scope.order['order_sub_type'] = value;
  scope.dateSingleOrRange = this.dateSingleOrRange(scope);
}


OrderCtrl.prototype.dateSingleOrRange = function(scope) {
  console.log(scope.order);

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



