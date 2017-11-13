var circaControllers = angular.module('circaControllers', []);

// Base prototype with methods/properties shared by all controllers

var CircaCtrl = function($scope, $route, $routeParams, $location, $window,
    $modal, apiRequests, sessionCache, commonUtils, formUtils) {

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

  // set debug to true for development only!
  if (this.commonUtils.railsEnv() == 'development') {
    $scope.debug = true;
  }

  // for angucomplete-alt
  $scope.angucompleteRequestFormatter = function(str) {
    return { q: encodeURIComponent(str) }
  }

  var processCache = function(cache) {
    _this.processCache(cache, $scope);
  }

  var cache = sessionCache.init(processCache);

  this.assignUtilitiesToScope($scope);

  this.applyItemFunctions($scope);

  this.applyLocationFunctions($scope);

  this.applyOrderFunctions($scope);

  this.applySharedUtilityFunctions($scope);

  this.applyUserFunctions($scope);

};


CircaCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window',
  '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];

circaControllers.controller('CircaCtrl', CircaCtrl);


CircaCtrl.prototype.processCache = function(cache, scope) {
  scope.currentUser = cache.get('currentUser');
  scope.assignableRoles = cache.get('currentUser')['assignable_roles'];
  scope.currentUserIsAdmin = scope.currentUser['is_admin'] ? true : false;
  this.controlledValues = cache.get('controlledValues');
  scope.controlledValues = cache.get('controlledValues');
  scope.circaLocations = cache.get('circaLocations');
  scope.orderStatesEvents = cache.get('orderStatesEvents');
  scope.itemStatesEvents = cache.get('itemStatesEvents');
  scope.options = cache.get('options');
}


CircaCtrl.prototype.assignUtilitiesToScope = function(scope) {
  var _this = this;
  scope.commonUtils = this.commonUtils;
  scope.formUtils = this.formUtils;
  scope.stateRegionValues = this.formUtils.stateRegionValues();
  scope.urlHelpers = this.urlHelpers;
  scope.rootPath = this.rootPath;
  // Assign templateUrl function $scope for convenience
  this.templateUrl = function(template) {
    return _this.urlHelpers.templateUrl(template);
  }
  scope.templateUrl = this.templateUrl;
  scope.searchParams = { 'active': null };
  scope.adminOverrideEnabled = false;
}


// Set current options for states and events for current order and its items
CircaCtrl.prototype.setStatesEvents = function(scope) {
  var processStatesEvents = function(record) {
    var processedStatesEvents = [];
    var statesEvents = record['states_events'];

    // console.log(statesEvents);

    var currentStateIndex = statesEvents.length - 1;
    var currentStateIndex;
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

  if (scope.order && scope.order['states_events']) {
    scope.statesEvents = processStatesEvents(scope.order);
    if (scope.order['item_orders']) {
      scope.order['item_orders'].forEach( function(item_order, i) {
        var item = item_order['item'];
        scope.order['item_orders'][i]['item']['states_events'] = processStatesEvents(item);
      });
    }
  }

}
