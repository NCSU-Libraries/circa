CircaCtrl.prototype.getPage = function(page, config, callback) {
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


CircaCtrl.prototype.search = function() {
  this.searchParams['active'] = true;
  this.getPage();
}


CircaCtrl.prototype.searchKeyEvents = function(keyEvent) {
  if (keyEvent.which === 13) {
    alert('I am an alert');
  }
}


CircaCtrl.prototype.searchReset = function() {
  this.searchParams['q'] = null;
  this.searchParams['active'] = null;
  this.getPage();
}


CircaCtrl.prototype.sortList = function(sort, sortOrder) {
  if (['asc', 'desc'].indexOf(sortOrder) < 0) {
    sortOrder = 'asc';
  }
  this.sort = sort + ' ' + sortOrder;
  this.getPage();
}


CircaCtrl.prototype.reverseSortOrder = function() {
  var currentSortOrder = this.sort.split(' ')[1];
  var sort = this.sort.split(' ')[0];
  var sortOrder = (currentSortOrder == 'asc') ? 'desc' : 'asc';
  this.sortList(sort, sortOrder);
}


CircaCtrl.prototype.initializeFilterConfig = function() {
  var _this = this;
  this.filterConfig = { show: false, filters: {}, options: {}, appliedFilters: null, filtersApplied: false};
}


// Override this method on inheritor classes if any filters require special treatment
CircaCtrl.prototype.setAppliedFilters = function() {
  this.filterConfig.appliedFilters = {};
  var filters = this.filterConfig.filters;
  for (var f in filters) {
    this.filterConfig.appliedFilters[f] = filters[f];
  }
  this.filterConfig.filtersApplied = Object.keys(this.filterConfig.appliedFilters).length > 0 ? true : false;
}


CircaCtrl.prototype.toggleShowFilters = function() {
  this.filterConfig['show'] = (this.filterConfig['show']) ? false : true;
}


CircaCtrl.prototype.addUserFilter = function(user) {
  this.filterConfig.filters['user_email'] = user.email;
}


CircaCtrl.prototype.addAssigneeFilter = function(user) {
  this.filterConfig.filters['assignee_email'] = user.email;
}


CircaCtrl.prototype.applyFilters = function() {
  this.page = null;
  this.getPage();
}


CircaCtrl.prototype.removeFilter = function(filter) {
  delete this.filterConfig.filters[filter];
  this.page = null;
  this.getPage();
}


CircaCtrl.prototype.resetFilter = function(filter) {
  delete this.filterConfig['filters'][filter];

  if (filter == 'assignee_email') {
    this.assigneeSelect = this.initializeUserSelect();
  }

  if (filter == 'user_email') {
    this.userSelect = this.initializeUserSelect();
  }
}


CircaCtrl.prototype.resetFilters = function() {
  var _this = this;
  Object.keys(_this.routeParams).forEach(function(key) {
    if (key.match(/^filters\[/)) {
      delete _this.routeParams[key];
      _this.location.search(key, null);
    }
  });
  _this.initializeFilterConfig();
  this.getPage();
}


CircaCtrl.prototype.deleteLocationSearch = function() {
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
    this.flash = message;
  }
}


CircaCtrl.prototype.toggleAdminOverride = function() {
  this.adminOverrideEnabled = this.adminOverrideEnabled ? false : true;
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


// Add list config options passed in routerParams to this
CircaCtrl.prototype.processListParams = function() {

  var _this = this;

  if (!this.sort && this.routeParams['sort']) {
    this.sort = this.routeParams['sort'];
  }

  if (!this.page && this.routeParams['page']) {
    this.page = this.routeParams['page'];
  }

  if (!this.searchParams['q'] && this.routeParams['q']) {
    this.searchParams['q'] = this.routeParams['q'];
    this.searchParams.active = true;
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
    this.filterConfig['filters'] = filters;
    this.setAppliedFilters();
  }
}


CircaCtrl.prototype.listRequestConfig = function() {

  var config = { params: {} };

  if (this.searchParams['q']) {
    config['params']['q'] = this.searchParams['q'];
  }
  if (this.sort) {
    config['params']['sort'] = this.sort;
  }
  if (this.page) {
    config['params']['page'] = this.page;
  }

  var filters = this.filterConfig['filters'];
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


CircaCtrl.prototype.removeNote = function(record, index) {
  this.removedNotes = this.removedNotes || [];
  if (record['notes'][index]) {
    var removed = record['notes'].splice(index,1);
    removed = removed[0];
    this.removedNotes.push(removed);
  }
}


CircaCtrl.prototype.restoreNote = function(record, note) {
  if (this.removedNotes) {
    var _this = this;
    var restoreNoteIndex = this.removedNotes.indexOf(note);
    if (restoreNoteIndex >= 0) {
      this.removedNotes.splice(restoreNoteIndex, 1);
      record['notes'].push(note);
    }
    return true;
  }
}


CircaCtrl.prototype.confirmDeleteRecord = function(recordType, record, redirectPath) {
  this.showRecordDeleteModal = true;
  this.recordToDeleteType = recordType;
  this.recordToDelete = record;
  this.deleteRedirectPath = redirectPath;
}


CircaCtrl.prototype.closeDeleteRecordModal = function() {
  this.showRecordDeleteModal = false;
  this.recordToDeleteType = null;
  this.recordToDelete = null;
  this.deleteRedirectPath = null;
}


CircaCtrl.prototype.deleteRecord = function() {
  if (this.recordToDelete) {
    var _this = this;
    var recordType = this.recordToDeleteType;
    var recordId = this.recordToDelete.id;

    var pathRoot = {
      order: 'orders',
      item: 'items',
      user: 'users',
      location: 'locations',
      enumerationValue: 'enumeration_values',
      userRole: 'user_roles'
    }

    var defaultRedirectPath = '/' + pathRoot[recordType]
    var redirectPath = this.deleteRedirectPath || defaultRedirectPath;

    var redirectQ = "deleted_record_id=" + recordId;
    var redirectQOperator = redirectPath.match(/\?/) ? '&' : '?';
    redirectPath = redirectPath + redirectQOperator + redirectQ;

    var apiPath = '/' + pathRoot[recordType] + '/' + recordId;

    this.apiRequests.delete(apiPath).then(function(response) {
      if (response.status == 200) {
        _this.closeDeleteRecordModal();
        if (recordType == 'location') {
          _this.sessionCache.refresh('circaLocations');
        }
        _this.flash = _this.capitalize(recordType) + ' ' + recordId + ' has been deleted';
        _this.goto(redirectPath, true, _this.flash);
      }
      else if (response.data['error'] && response.data['error']['detail']) {
        _this.flash = response.data['error']['detail'];
      }
    });
  }
  else {
    this.flash = "Application error: recordToDelete not set"
  }
}


CircaCtrl.prototype.openArchivesSpaceRecord = function(uri) {
  var url = this.rootPath() + '/archivesspace_resolver' + uri;
  this.window.open(url);
}


CircaCtrl.prototype.paramsToQueryString = function(params) {
  this.location.search(params);
}



CircaCtrl.prototype.capitalize = function (string) {
  if (string && typeof string === 'string') {
    return string.charAt(0).toUpperCase() + string.slice(1);
  }
}
