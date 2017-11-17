CircaCtrl.prototype.applySharedUtilityFunctions = function(scope) {

  var _this = this;

  scope.getPage = function(page, config, callback) {
    _this.getPage(scope, page, config, callback);
  }

  scope.search = function() {
    _this.search(scope);
  }

  scope.searchReset = function() {
    _this.searchReset(scope);
  }

  scope.sortList = function(sort, sortOrder) {
    _this.sortList(scope, sort, sortOrder);
  }

  scope.reverseSortOrder = function() {
    _this.reverseSortOrder(scope);
  }

  scope.toggleShowFilters = function() {
    _this.toggleShowFilters(scope);
  }

  scope.applyFilters = function() {
    _this.applyFilters(scope);
  }

  scope.resetFilters = function() {
    _this.resetFilters(scope);
  }

  scope.resetFilter = function(filter) {
    _this.resetFilter(scope, filter);
  }

  scope.toggleAdminOverride = function() {
    _this.toggleAdminOverride(scope);
  }

  scope.confirmDeleteRecord = function(recordType, record, redirectPath) {
    _this.confirmDeleteRecord(scope, recordType, record, redirectPath);
  }

  scope.goto = function(path, reload) {
    _this.goto(path, reload);
  }

  scope.openArchivesSpaceRecord = function(uri) {
    _this.openArchivesSpaceRecord(scope, uri);
  }

}


// This method must be overridden by any class that inherit from CircaCtrl,
// The inherited method will in turn call a more specific method to retrieve a single page of records of a specified type
CircaCtrl.prototype.getPage = function(scope, page, config, callback) {
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


CircaCtrl.prototype.deleteLocationSearch = function(scope) {
  var _this = this;
  Object.keys(_this.location.search()).forEach(function(key) {
    _this.location.search(key, null);
  });
}


CircaCtrl.prototype.goto = function(path, reload, message) {

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


CircaCtrl.prototype.addNote = function(record, callback) {
  if (record['notes'].indexOf('') < 0) {
    record['notes'].push( { 'content': '' } );
  }
}


CircaCtrl.prototype.removeNote = function(scope, record, index) {
  scope.removedNotes = scope.removedNotes || [];
  if (record['notes'][index]) {
    var removed = record['notes'].splice(index,1);
    removed = removed[0];
    scope.removedNotes.push(removed);
  }
}


CircaCtrl.prototype.restoreNote = function(scope, record, note) {
  if (scope.removedNotes) {
    var _this = this;
    var restoreNoteIndex = scope.removedNotes.indexOf(note);
    if (restoreNoteIndex >= 0) {
      scope.removedNotes.splice(restoreNoteIndex, 1);
      record['notes'].push(note);
    }
    return true;
  }
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


CircaCtrl.prototype.openArchivesSpaceRecord = function(scope, uri) {
  var url = this.rootPath() + '/archivesspace_resolver' + uri;
  this.window.open(url);
}


CircaCtrl.prototype.paramsToQueryString = function(params) {
  this.location.search(params);
}

