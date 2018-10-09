var circaControllers = angular.module('circaControllers', []);

// Base prototype with methods/properties shared by all controllers

var CircaCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  var _this = this;

  this.location = $location;
  this.window = $window;
  this.route = $route;
  this.routeParams = $routeParams;
  this.commonUtils = commonUtils;
  this.formUtils = formUtils;
  this.stateRegionValues = formUtils.stateRegionValues();
  this.urlHelpers = commonUtils.urlHelpers;
  this.rootPath = this.urlHelpers.rootPath;
  this.apiRequests = apiRequests;
  this.sessionCache = sessionCache;

  this.setDefaults();

  var processCache = function(cache) {
    _this.processCache(cache);
  }

  var cache = sessionCache.init(processCache);
};


CircaCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];

circaControllers.controller('CircaCtrl', CircaCtrl);


CircaCtrl.prototype.processCache = function(cache) {
  this.currentUser = cache.get('currentUser');
  this.assignableRoles = cache.get('currentUser')['assignable_roles'];
  this.currentUserIsAdmin = this.currentUser['is_admin'] ? true : false;
  this.controlledValues = cache.get('controlledValues');
  this.controlledValues = cache.get('controlledValues');
  this.circaLocations = cache.get('circaLocations');
  this.orderStatesEvents = cache.get('orderStatesEvents');
  this.itemStatesEvents = cache.get('itemStatesEvents');
  this.options = cache.get('options');
}


CircaCtrl.prototype.setDefaults = function() {
  this.searchParams = { 'active': null };
  this.adminOverrideEnabled = false;

  // set debug to true for development only!
  // if (this.commonUtils.railsEnv() == 'development') {
  //   this.debug = true;
  // }
}


CircaCtrl.prototype.templateUrl = function(template) {
  return this.urlHelpers.templateUrl(template);
}


// Set current options for states and events for current order and its items
CircaCtrl.prototype.setStatesEvents = function() {
  var _this = this;
  var processStatesEvents = function(record) {
    var processedStatesEvents = [];
    var statesEvents = record['states_events'];
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

  if (this.order && this.order['states_events']) {
    this.statesEvents = processStatesEvents(this.order);
    if (this.order['item_orders']) {
      this.order['item_orders'].forEach( function(item_order, i) {
        var item = item_order['item'];
        _this.order['item_orders'][i]['item']['states_events'] = processStatesEvents(item);
      });
    }
  }
}

 // for angucomplete-alt
CircaCtrl.prototype.angucompleteRequestFormatter = function(str) {
  return { q: encodeURIComponent(str) }
}


// Declared here but overridden by inherited controllers
CircaCtrl.prototype.customTemplates = function(templateName) {
  console.log('this.customTemplates');
  return null
}


CircaCtrl.prototype.deletedRecordFlash = function(recordType) {
  if (this.location.search().deleted_record_id) {
    var deletedId = this.location.search().deleted_record_id;
    this.flash = this.capitalize(recordType) + ' ' +  deletedId + " has been deleted."
  }
}


CircaCtrl.prototype.customTemplateExists = function(templateName) {
  var template;
  template = this.customTemplates(templateName) || null;
  return template ? true : false;
}

CircaCtrl.prototype.customTemplateUrl = function(templateName) {
  var customTemplate = this.customTemplates(templateName) || 'common/blank';
  return this.templateUrl(customTemplate);
}

CircaCtrl.prototype.test = function(string) {
  console.log("test output: " + string)
}
