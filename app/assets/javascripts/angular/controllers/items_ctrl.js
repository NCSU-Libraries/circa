var ItemsCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  var _this = this;

  this.section = 'items';

  CircaCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  this.apiRequests = apiRequests;
  this.location = $location;
  this.window = $window;

  this.initializeFilterConfig();
}

ItemsCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];

ItemsCtrl.prototype = Object.create(CircaCtrl.prototype);

circaControllers.controller('ItemsCtrl', ItemsCtrl);


ItemsCtrl.prototype.getPage = function(page) {
  this.getItems(page);
}


ItemsCtrl.prototype.getItems = function(page) {
  this.loading = true;
  var path = '/items';
  var _this = this;
  page = page ? page : 1;
  this.page = page;

  var config = this.listRequestConfig();

  this.updateLocationQueryParams(config['params']);

  this.apiRequests.getPage(path, page, config).then(function(response) {
    _this.loading = false;
    if (response.status == 200) {
      _this.items = response.data['items'];
      var paginationParams = _this.commonUtils.paginationParams(response.data['meta']['pagination']);
      _this.commonUtils.objectMerge(_this, paginationParams);
    }
  });
}


ItemsCtrl.prototype.getItem = function(id, callback) {
  var path = '/items/' + id;
  var _this = this;
  this.apiRequests.get(path).then(function(response) {
    if (response.status == 200) {
      _this.item = response.data['item'];
      _this.commonUtils.executeCallback(callback);
    }
    else {
      _this.error = response.data['error'];
    }
  });
}


ItemsCtrl.prototype.getItemMovementHistory = function(id, callback) {
  var path = '/items/' + id + '/movement_history';
  var _this = this;
  this.apiRequests.get(path).then(function(response) {
    if (response.status == 200) {
      if (_this['item']) {
        _this['item']['movement_history'] =
            response.data['item']['movement_history'];
      }
      _this.commonUtils.executeCallback(callback);
    }
    else {
      _this.error = response.data['error'];
    }
  });
}


ItemsCtrl.prototype.getItemModificationHistory = function(id, callback) {
  var path = '/items/' + id + '/modification_history';
  var _this = this;
  this.apiRequests.get(path).then(function(response) {
    if (response.status == 200) {
      if (_this['item']) {
        _this['item']['modification_history'] =
            response.data['item']['modification_history'];
      }
      _this.commonUtils.executeCallback(callback);
    }
    else {
      _this.error = response.data['error'];
    }
  });
}


ItemsCtrl.prototype.openItemObsoleteModal = function() {
  this.showItemObsoleteModal = true;
}


ItemsCtrl.prototype.closeItemObsoleteModal = function() {
  this.showItemObsoleteModal = false;
}


ItemsCtrl.prototype.obsoleteItem = function(id) {
  this.showItemObsoleteModal = false;
  this.loading = true;
  var path = '/items/' + id + '/obsolete';
  var _this = this;
  this.apiRequests.put(path).then(function(response) {
    _this.loading = false;
    if ((response.status - 200) < 100) {
      _this.item = response.data['item'];
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.flash = response.data['error']['detail'];
    }
  });
}
