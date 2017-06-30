var circaControllers = angular.module('circaControllers', []);


// See http://www.technofattie.com/2014/03/21/five-guidelines-for-avoiding-scope-soup-in-angular.html


// Base prototype with methods/properties shared by all controllers

var CircaCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {

  var _this = this;

  this.location = $location;
  this.window = $window;
  this.modal = $modal;
  this.route = $route;
  this.routeParams = $routeParams;
  this.commonUtils = commonUtils;
  this.formUtils = formUtils;
  this.urlHelpers = commonUtils.urlHelpers;
  this.rootPath = this.urlHelpers.rootPath;
  this.apiRequests = apiRequests;
  this.sessionCache = sessionCache;
  // Assign templateUrl function $scope for convenience
  this.templateUrl = function(template) {
    return _this.urlHelpers.templateUrl(template);
  }

  // set debug to true for development only!
  if (this.commonUtils.railsEnv() == 'development') {
    $scope.debug = true;
  }

  $scope.commonUtils = this.commonUtils;
  $scope.formUtils = this.formUtils;
  $scope.stateRegionValues = formUtils.stateRegionValues();
  $scope.urlHelpers = this.urlHelpers;
  $scope.rootPath = this.rootPath;
  $scope.templateUrl = this.templateUrl;
  $scope.searchParams = { 'active': null };
  $scope.adminOverrideEnabled = false;

  // for angucomplete-alt
  $scope.angucompleteRequestFormatter = function(str) {
    return { q: encodeURIComponent(str) }
  }


  $scope.processCache = function(cache) {
    _this.processCache(cache, $scope);
  }

  var cache = sessionCache.init($scope.processCache);

  $scope.getPage = function(page, config, callback) {
    _this.getPage($scope, page, config, callback);
  }


  this.showItem = function(itemId) {
    _this.goto('items/' + itemId);
  }

  $scope.showItem = function(itemId) {
    _this.showItem(itemId);
  }



  this.showItemHistory = function(itemId) {
    _this.goto('items/' + itemId + '/history');
  }

  $scope.showItemHistory = function(itemId) {
    _this.showItemHistory(itemId);
  }



  this.showOrder = function(orderId) {
    _this.goto('orders/' + orderId);
  }

  $scope.showOrder = function(orderId) {
    _this.showOrder(orderId);
  }



  $scope.editOrder = function(orderId) {
    _this.goto('orders/' + orderId + '/edit');
  }



  this.showLocation = function(locationId) {
    _this.goto('locations/' + locationId);
  }

  $scope.showLocation = function(locationId) {
    _this.showLocation(locationId);
  }



  this.editLocation = function(locationId) {
    _this.goto('locations/' + locationId + '/edit');
  }

  $scope.editLocation = function(locationId) {
    _this.editLocation(locationId);
  }



  this.showUser = function(userId) {
    _this.goto('users/' + userId);
  }

  $scope.showUser = function(userId) {
    _this.showUser(userId);
  }



  this.editUser = function(userId) {
    _this.goto('users/' + userId + '/edit');
  }

  $scope.editUser = function(userId) {
    _this.editUser(userId);
  }


  $scope.triggerOrderEvent = function(orderId, event, callback) {
    _this.triggerOrderEvent($scope, orderId, event, callback);
  }

  $scope.triggerItemEvent = function(itemId, event, callback) {
    _this.triggerItemEvent($scope, itemId, event, callback);
  }

  $scope.initializeCheckOut = function(itemId, orderId) {
    _this.initializeCheckOut($scope, itemId, orderId);
  }

  $scope.checkOutItem = function(item, users, callback) {
    _this.checkOutItem($scope, item, users, callback);
  }

  $scope.receiveItemAtTemporaryLocation = function(item, callback) {
    _this.receiveItemAtTemporaryLocation($scope, item, callback)
  }

  $scope.checkInItem = function(item, callback) {
    _this.checkInItem($scope, item, callback);
  }

  $scope.confirmDeleteRecord = function(recordType, record, redirectPath) {
    _this.confirmDeleteRecord($scope, recordType, record, redirectPath);
  }

  $scope.goto = function(path, reload) {
    _this.goto(path, reload);
  }

  $scope.enableItemLocationChange = function(item) {
    _this.enableItemLocationChange($scope, item);
  }

  $scope.changeItemLocation = function() {
    _this.changeItemLocation($scope);
  }

  // Search/sort/filter

  // $scope.refreshList = function() {
  //   _this.refreshList($scope);
  // }

  $scope.search = function() {
    _this.search($scope);
  }

  $scope.searchReset = function() {
    _this.searchReset($scope);
  }

  $scope.sortList = function(sort, sortOrder) {
    _this.sortList($scope, sort, sortOrder);
  }

  $scope.reverseSortOrder = function() {
    _this.reverseSortOrder($scope);
  }

  $scope.toggleShowFilters = function() {
    _this.toggleShowFilters($scope);
  }

  $scope.applyFilters = function() {
    _this.applyFilters($scope);
  }

  $scope.resetFilters = function() {
    _this.resetFilters($scope);
  }

  $scope.resetFilter = function(filter) {
    _this.resetFilter($scope, filter);
  }

  $scope.toggleAdminOverride = function() {
    _this.toggleAdminOverride($scope);
  }

  $scope.bulkItemEvents = function() {
    return _this.bulkItemEvents($scope);
  }

  $scope.bulkTriggerItemEvent = function(event) {
    _this.bulkTriggerItemEvent($scope, event);
  }

  $scope.selectNewActiveOrder = function(item) {
    _this.selectNewActiveOrder($scope, item);
  }

  $scope.openArchivesSpaceRecord = function(uri) {
    _this.openArchivesSpaceRecord($scope, uri);
  }

  $scope.removedNotes = [];

};


CircaCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];

circaControllers.controller('CircaCtrl', CircaCtrl);


// This method must be overridden by any class that inherit from CircaCtrl,
// THe inherited method will in turn call a more specific method to retrieve a single page of records of a specified type
CircaCtrl.prototype.getPage = function(scope, page, config, callback) {
}


// Search/sort/filter


// Add list config options passed in routerParams to scope
CircaCtrl.prototype.processListParams = function(scope) {

  var _this = this;
  if (!scope.sort && this.routeParams['sort']) {
    scope.sort = this.routeParams['sort'];
  }
  if (!scope.page && this.routeParams['page']) {
    scope.page = this.routeParams['page'];
  }
  if (!scope.searchParams['q'] && this.routeParams['q']) {
    scope.searchParams['q'] = this.routeParams['q'];
    scope.searchParams.active = true;
  }

  var filters = {};
  var hasFilters;
  Object.keys(this.routeParams).forEach(function(key) {
    if (key.match(/^filters\[/)) {
      hasFilters = true;
      var filter = key.replace(/filters\[/,'').replace(/]/,'');
      filters[filter] = _this.routeParams[key];
    }
  });
  if (hasFilters) {
    scope.filterConfig['filters'] = filters;
    this.setAppliedFilters(scope);
  }
}


CircaCtrl.prototype.listRequestConfig = function(scope) {

  var config = { params: {} };

  if (scope.searchParams['q']) {
    config['params']['q'] = scope.searchParams['q'];
  }
  if (scope.sort) {
    config['params']['sort'] = scope.sort;
  }
  if (scope.page) {
    config['params']['page'] = scope.page;
  }

  var filters = scope.filterConfig['filters'];
  for (var f in filters) {
    config['params']['filters[' + f + ']'] = filters[f];
  }
  return config;
}


CircaCtrl.prototype.updateLocationQueryParams = function(params) {
  var searchCheck = false;

  for (var key in params) {
    if (key == 'page') {
      if (params['page'] != '1') {
        searchCheck = true;
        break;
      }
    }
    else if (params.hasOwnProperty(key) && params[key] ) {
      searchCheck = true;
      break;
    }
  }

  if (searchCheck) {
    this.location.search( params );
  }
}



CircaCtrl.prototype.search = function(scope) {
  scope.searchParams['active'] = true;
  this.getPage(scope);
}


CircaCtrl.prototype.searchReset = function(scope) {
  scope.searchParams['q'] = null;
  scope.searchParams['active'] = null;
  this.getPage(scope);
}



CircaCtrl.prototype.sortList = function(scope, sort, sortOrder) {
  if (['asc', 'desc'].indexOf(sortOrder) < 0) {
    sortOrder = 'asc';
  }
  scope.sort = sort + ' ' + sortOrder;
  this.getPage(scope);
}


CircaCtrl.prototype.reverseSortOrder = function(scope) {
  var currentSortOrder = scope.sort.split(' ')[1];
  var sort = scope.sort.split(' ')[0];
  var sortOrder = (currentSortOrder == 'asc') ? 'desc' : 'asc';
  this.sortList(scope, sort, sortOrder);
}



CircaCtrl.prototype.initializeFilterConfig = function(scope) {
  var _this = this;
  scope.filterConfig = { show: false, filters: {}, options: {}, appliedFilters: null, filtersApplied: false};
}


// Override this method on inheritor classes if any filters require special treatment
CircaCtrl.prototype.setAppliedFilters = function(scope) {
  scope.filterConfig.appliedFilters = {};
  var filters = scope.filterConfig.filters;
  for (var f in filters) {
    scope.filterConfig.appliedFilters[f] = filters[f];
  }
  scope.filterConfig.filtersApplied = Object.keys(scope.filterConfig.appliedFilters).length > 0 ? true : false;
}


CircaCtrl.prototype.toggleShowFilters = function(scope) {
  scope.filterConfig['show'] = (scope.filterConfig['show']) ? false : true;
}


CircaCtrl.prototype.applyFilters = function(scope) {
  scope.page = null;
  this.getPage(scope);
}

CircaCtrl.prototype.resetFilter = function(scope, filter) {
  delete scope.filterConfig['filters'][filter];
}


CircaCtrl.prototype.resetFilters = function(scope) {
  var _this = this;
  Object.keys(_this.routeParams).forEach(function(key) {
    if (key.match(/^filters\[/)) {
      delete _this.routeParams[key];
      _this.location.search(key, null);
    }
  });
  _this.initializeFilterConfig(scope);
  this.getPage(scope);
}


// cache

CircaCtrl.prototype.processCache = function(cache, scope) {
  scope.currentUser = cache.get('currentUser');
  scope.assignableRoles = cache.get('currentUser')['assignable_roles'];
  scope.currentUserIsAdmin = scope.currentUser['is_admin'] ? true : false;
  scope.controlledValues = cache.get('controlledValues');
  scope.circaLocations = cache.get('circaLocations');
  scope.orderStatesEvents = cache.get('orderStatesEvents');
  scope.itemStatesEvents = cache.get('itemStatesEvents');
  scope.options = cache.get('options');

  for (var i = 0; i < scope.circaLocations.length; i++) {
    if (scope.circaLocations[i]['default'] == true) {
      scope.defaultLocation = scope.circaLocations[i];
      return;
    }
  }
}


CircaCtrl.prototype.deleteLocationSearch = function(scope) {
  var _this = this;
  Object.keys(_this.location.search()).forEach(function(key) {
    _this.location.search(key, null);
  });
}


CircaCtrl.prototype.goto = function(path, reload, message) {

  console.log(path);

  var searchParams = {}
  if (path.match(/\?/)) {
    var pathSplit = path.split('?');
    var q_string = pathSplit[1];
    path = pathSplit[0];
    q_string.split('&').forEach(function(subString) {
      var subStringSplit = subString.split('=');
      searchParams[subStringSplit[0]] = subStringSplit[1];
    });
    console.log(q_string);
  }

  var referrerPath = this.location.path;

  if (!path.match(/^\//)) {
    path = '/' + path;
  }

  this.window.scroll(0,0);
  this.deleteLocationSearch();
  this.location.path(path).search(searchParams);
  if (reload) {
    this.route.reload();
  }
  if (message) {
    alert(message);
  }
}


CircaCtrl.prototype.toggleAdminOverride = function(scope) {
  scope.adminOverrideEnabled = scope.adminOverrideEnabled ? false : true;
}





// CircaCtrl.prototype.getEnumerationValueId = function(scope, enumerationValues, enumerationValueShort) {
//   var id;

//   $.each(enumerationValues, function(index, value) {
//     if (value['value_short'] == enumerationValueShort) {
//       id = value['id'];
//       return false;
//     }
//   });
//   return id;
// }


// CircaCtrl.prototype.getEnumerationValue = function(enumerationValues, enumerationValueId) {
//   var enumerationValue;

//   $.each(enumerationValues, function(index, value) {
//     if (value['id'] == enumerationValueId) {
//       enumerationValue = value;
//       return false;
//     }
//   });
//   return enumerationValue;
// }


CircaCtrl.prototype.getControlledValue = function(controlledValues, controlledValueId) {
  var controlledValue;

  for (var i = 0; i < controlledValues.length; i ++) {
    var value = controlledValues[i];
    if (value['id'] == controlledValueId) {
      controlledValue = value;
      break;
    }
  }
  return controlledValue;
}



CircaCtrl.prototype.getUser = function(scope, userId, callback) {
  scope.loading = true;
  var path = '/users/' + userId;
  var _this = this;
  // var params = { user_type: 'user' };
  var params = {};

  this.apiRequests.get(path, { 'params': params } ).then(function(response) {
    if (response.status == 200) {
      scope.loading = false;
      _this.refreshUser(scope, response.data['user'], callback)
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
}


CircaCtrl.prototype.refreshUser = function(scope, user, callback) {
  scope.user = user;
  scope.user['open_orders'] = scope.user['orders'].filter(function(o) { return o['open']; });
  scope.user['completed_orders'] = scope.user['orders'].filter(function(o) { return !o['open']; });
  this.commonUtils.executeCallback(callback, scope);
}


// Set current options for states and events for current order and its items
CircaCtrl.prototype.setStatesEvents = function(scope) {
  var processStatesEvents = function(record) {
    var processedStatesEvents = [];
    var statesEvents = record['states_events'];
    var currentStateIndex = statesEvents.length - 1;
    var currentState = record['current_state'];
    var availableEvents = record['available_events'];
    var permittedEvents = record['permitted_events'];
    $.each(statesEvents, function(i, array) {
      var stateEvent = {
        state: array[0],
        event: array[1],
        eventDescription: array[2],
        current: (currentState == array[0]) ? true : false,
        available: (availableEvents.indexOf(array[1]) >= 0) ? true : false,
        permitted: (permittedEvents.indexOf(array[1]) >= 0) ? true : false
      }

      if (currentState == array[0]) {
        currentStateIndex = i;
      }

      stateEvent['complete'] = (i <= currentStateIndex) ? true : false;
      processedStatesEvents.push(stateEvent);
    });
    return processedStatesEvents;
  }

  if (scope.order) {
    scope.statesEvents = processStatesEvents(scope.order);
    if (scope.order['items']) {
      $.each(scope.order['items'], function(i, item) {
        scope.order['items'][i]['statesEvents'] = processStatesEvents(item);
      });
    }
  }
}


CircaCtrl.prototype.paramsToQueryString = function(params) {
  var _this = this;
  _this.location.search(params);
}


CircaCtrl.prototype.setCheckOutAvailable = function(scope) {
  if (scope.order) {
    if (scope.order['order_type']['name'] == 'research') {
      scope.order['checkOutAvailable'] = true;
    }
    else {
      scope.order['checkOutAvailable'] = false;
    }
  }
}


CircaCtrl.prototype.getOrder = function(scope, id, callback) {
  var path = '/orders/' + id;
  var _this = this;
  scope.loading = true;
  this.apiRequests.get(path).then(function(response) {
    if (response.status == 200) {
      scope.loading = false;
      _this.refreshOrder(scope, response.data['order'], callback)
      // scope.order = response.data['order'];
      // _this.collectItemIds(scope, response.data['order']);
      // _this.collectUserEmails(scope, response.data['order']);
      // _this.collectAssigneeEmails(scope, response.data['order']);
      // _this.setStatesEvents(scope);
      // _this.setCheckOutAvailable(scope);
      // _this.commonUtils.executeCallback(callback, scope);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.errorCode = response.status;
      scope.flash = response.data['error']['detail'];
    }
  });
}


CircaCtrl.prototype.refreshOrder = function(scope, order, callback) {
  scope.order = order;
  this.collectItemIds(scope, order);
  this.collectUserEmails(scope, order);
  this.collectAssigneeEmails(scope, order);
  this.setStatesEvents(scope);
  this.setCheckOutAvailable(scope);
  this.commonUtils.executeCallback(callback, scope);
}


CircaCtrl.prototype.updateOrder = function(scope, callback) {
  if (scope.order) {
    this.getOrder(scope, scope.order['id'], callback);
  }
}


// Trigger event for order and reset $scope.order['states_events']
CircaCtrl.prototype.triggerOrderEvent = function(scope, orderId, event, callback) {
  var path = '/orders/' + orderId + '/' + event;
  var _this = this;
  scope.orderEventLoading = true;
  _this.apiRequests.put(path).then(function(response) {
    scope.orderEventLoading = false;
    if (response.status == 200) {
      scope.order = response.data['order'];
      _this.setStatesEvents(scope);
      _this.commonUtils.executeCallback(callback, response.data);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
}


// Trigger event for item
CircaCtrl.prototype.triggerItemEvent = function(scope, itemId, event, callback) {
  var path = '/items/' + itemId + '/' + event;
  var _this = this;
  var data = { 'order_id': scope.order['id'] };
  scope.itemEventLoading = true;
  _this.apiRequests.put(path, data).then(function(response) {

    scope.itemEventLoading = false;

    if (response.status == 200) {

      if (scope.order && response.data['order']) {
        scope.order = response.data['order'];
      }
      else if (scope.order && !response.data['order']) {
        _this.updateOrder(scope);
      }
      // else if (scope.item && !response.data['item']) {
      //   _this.updateItemscope);
      // }

      _this.commonUtils.executeCallback(callback, response.data);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
}


CircaCtrl.prototype.bulkTriggerItemEvent = function(scope, event) {
  var _this = this;
  if (scope.order && scope.order['items']) {
    scope.order['items'].forEach(function(item) {
      if (item['permitted_events'].indexOf(event) >= 0) {
        if (event == 'receive_at_temporary_location') {
          _this.receiveItemAtTemporaryLocation(scope, item)
        }
        else {
          _this.triggerItemEvent(scope, item['id'], event);
        }
      }
    });
  }
}


CircaCtrl.prototype.bulkItemEvents = function(scope) {
  var skipEvents = [ 'report_not_found', 'check_out' ]
  if (scope.order && scope.order['items']) {
    var bulkEvents = {};
    scope.order['items'].forEach(function(item) {

      if (!item['obsolete']) {
        item['permitted_events'].forEach(function(event) {
          if (skipEvents.indexOf(event) < 0) {
            if (!bulkEvents[event]) {
              bulkEvents[event] = 1;
            }
            else {
              bulkEvents[event]++;
            }
          }
        });
      }

    });
    return bulkEvents;
  }
}


CircaCtrl.prototype.initializeCheckOut = function(scope) {
  var _this = this;
  scope.checkOutItemIds = [];
  scope.checkOutUserIds = [];
  scope.availableUsers = {};
  scope.toggleCheckout = function(itemId) {
    _this.commonUtils.toggleArrayElement(scope.checkOutItemIds, itemId);
  }

  if (scope.order && scope.order['users']) {
    $.each(scope.order['users'], function(index, user) {
      scope.availableUsers[user['id']] = user;
    });

    if (scope.order['users'].length == 1 && scope.order['users'][0]['agreement_confirmed']) {
      scope.checkOutUserIds.push(parseInt(scope.order['users'][0]['id']));
    }
  }
}


CircaCtrl.prototype.enableItemLocationChange = function(scope, item) {
  scope.itemLocationChangeEnabled = item['id'];
  scope.itemLocationChange = { 'item': item, 'locationId': item['current_location']['id'].toString() };
}


CircaCtrl.prototype.changeItemLocation = function(scope) {
  var _this = this;
  if (scope.itemLocationChange) {
    var item = scope.itemLocationChange['item'];
    var itemId = item['id'];
    var locationId = scope.itemLocationChange['locationId'];
    if (itemId && locationId) {
      item['current_location_id'] = locationId;
      var path = '/items/' + item['id'];
      var postData = { 'item': item };
      scope.itemLocationChange['loading'] = true;
      this.apiRequests.put(path, postData).then(function(response) {
        if (response.status == 200) {
          if (scope.order) {
            _this.getOrder(scope, scope.order['id']);
          }
          else if (scope.item) {
            _this.getItem(scope, scope.item['id']);
          }
          scope.itemLocationChangeEnabled = null;
          scope.itemLocationChange = { 'item': null, 'locationId': null };
        }
        else {
          if (response.data['error'] && response.data['error']['detail']) {
            scope.itemLocationChange['alert'] = response.data['error']['detail'];
          }
          else {
            scope.itemLocationChange['alert'] = "Unknown error"
          }
        }
      });
    }
  }
}


// Check out item
CircaCtrl.prototype.checkOutItem = function(scope, item, userIds, callback) {
  var _this = this;
  var path = '/items/' + item['id'] + '/check_out';
  var users = scope.order['users'].filter(function(user) {
    return userIds.indexOf(user['id']) >= 0;
  });

  var data = { 'users': users, 'order_id': scope.order['id'] };

  this.apiRequests.put(path, data).then(function(response) {
    if (response.status == 200) {

      if (scope.order) {
        _this.getOrder(scope, scope.order['id']);
      }
      else if (scope.item) {
        _this.getItem(scope, scope.item['id']);
      }
      _this.initializeCheckOut(scope);
      _this.commonUtils.executeCallback(callback, response.data);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
}


// Check in item
CircaCtrl.prototype.checkInItem = function(scope, item, callback) {
  scope.itemEventLoading = true;
  var _this = this;
  var path = '/items/' + item['id'] + '/check_in';
  var data = { 'order_id': scope.order['id'] };
  this.apiRequests.put(path, data).then(function(response) {
    scope.itemEventLoading = false;
    if (response.status == 200) {
      if (scope.order) {
        _this.getOrder(scope, scope.order['id']);
      }
      else if (scope.item) {
        _this.getItem(scope, scope.item['id']);
      }
      _this.initializeCheckOut(scope);
      _this.commonUtils.executeCallback(callback, response.data);
    }
  });
}


// Check out item
CircaCtrl.prototype.receiveItemAtTemporaryLocation = function(scope, item, callback) {
  scope.itemEventLoading = true;
  var _this = this;
  var path = '/items/' + item['id'] + '/receive_at_temporary_location';
  var data = { 'order_id': scope.order['id'] };

  this.apiRequests.put(path, data).then(function(response) {
    scope.itemEventLoading = false;
    if (response.status == 200) {

      if (scope.order) {
        _this.getOrder(scope, scope.order['id']);
      }
      else if (scope.item) {
        _this.getItem(scope, scope.item['id']);
      }
      _this.commonUtils.executeCallback(callback, response.data);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
}


// Collect associated item IDs to avoid duplication
CircaCtrl.prototype.collectItemIds = function(scope, order) {
  scope.itemIds = (typeof scope.itemIds === 'undefined') ? [] : scope.itemIds;
  function addItemIdsToScope(element, index, array) {
    if (scope.itemIds.indexOf(element['id'] < 0)) {
      scope.itemIds.push(element['id']);
    }
  }
  if (Array.isArray(order['items'])) {
    order['items'].forEach(addItemIdsToScope);
  }
}


// Collect associated user emails to avoid duplication
CircaCtrl.prototype.collectUserEmails = function(scope, order) {
  scope.userEmails = (typeof scope.userEmails === 'undefined') ? [] : scope.userEmails;
  function addEmailToScope(element, index, array) {
    scope.userEmails.push(element['email'])
  }
  if (Array.isArray(order['users'])) {
    order['users'].forEach(addEmailToScope);
  }
}


// Collect associated assignee emails to avoid duplication
CircaCtrl.prototype.collectAssigneeEmails = function(scope, order) {
  scope.assigneeEmails = (typeof scope.assigneeEmails === 'undefined') ? [] : scope.assigneeEmails;
  if (Array.isArray(order['assignees'])) {
    $.each(order['assignees'], function(index, user) {
      scope.assigneeEmails.push(user['email']);
    });
  }
}


CircaCtrl.prototype.getLocation = function(scope, id, callback) {
  var path = '/locations/' + id;
  var _this = this;
  _this.apiRequests.get(path).then(function(response) {
    if (response.status == 200) {
      scope.location = response.data['location'];
      _this.commonUtils.executeCallback(callback, scope);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
}


CircaCtrl.prototype.openArchivesSpaceRecord = function(scope, uri) {
  var url = this.rootPath() + '/archivesspace_resolver' + uri;
  this.window.open(url);
}


CircaCtrl.prototype.getLocations = function(scope, page, sort) {
  var path = '/locations';
  var _this = this;

  page = page ? page : 1;
  if (typeof sort !== 'undefined') {
    path = path + '?sort=' + sort;
  }
  this.apiRequests.getPage(path,page).then(function(response) {
    if (response.status == 200) {
      scope.locations = response.data['locations'];
      var paginationParams = _this.commonUtils.paginationParams(response.data['meta']['pagination']);
      _this.commonUtils.objectMerge(scope, paginationParams);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
}


CircaCtrl.prototype.confirmDeleteRecord = function(scope, recordType, record, redirectPath) {
  var _this = this;

  var modalInstance = _this.modal.open({
    templateUrl: _this.templateUrl('common/delete_record'),
    controller: 'CircaModalInstanceCtrl',
    resolve: {
      resolved: function() {
        return {
          recordType: recordType,
          record: record
        }
      }
    }
  });

  modalInstance.result.then(function (result) {
    _this.deleteRecord(scope, recordType, record, redirectPath);
  }, function () {
    console.log('Modal dismissed at: ' + new Date());
  });
}


CircaCtrl.prototype.deleteRecord = function(scope, recordType, record, redirectPath) {
  var _this = this;

  var pathRoot = {
    order: 'orders',
    item: 'items',
    user: 'users',
    location: 'locations',
    enumerationValue: 'enumeration_values',
    userRole: 'user_roles'
  }

  var redirectPath = redirectPath ? redirectPath : '/' + pathRoot[recordType];

  var apiPath = '/' + pathRoot[recordType] + '/' + record['id'];

  this.apiRequests.delete(apiPath).then(function(response) {
    if (response.status == 200) {
      if (recordType == 'location') {
        _this.sessionCache.refresh('circaLocations');
      }
      _this.goto(redirectPath, true);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
}


CircaCtrl.prototype.initializeUser = function() {
  return {
    email: '',
    first_name: '', last_name: '',
    position: '', affiliation: '',
    display_name: '',
    address1: '', address2: '', city: '', state: 'NC', zip: '', country: 'US', phone: '', agreement_confirmed_at: '',
    role: 'patron',
    notes: []
  }
}


CircaCtrl.prototype.addNote = function(scope, record, callback) {
  if (record['notes'].indexOf('') < 0) {
    record['notes'].push( { 'content': '' } );
  }
}


CircaCtrl.prototype.removeNote = function(scope, record, index) {
  if (record['notes'][index]) {
    var removed = record['notes'].splice(index,1);
    removed = removed[0];
    scope.removedNotes.push(removed);
  }
}


CircaCtrl.prototype.restoreNote = function(scope, record, note) {
  console.log(note);
  var _this = this;
  var restoreNoteIndex = scope.removedNotes.indexOf(note);
  if (restoreNoteIndex >= 0) {
    scope.removedNotes.splice(restoreNoteIndex, 1);
    record['notes'].push(note);
  }
  return true;
}

