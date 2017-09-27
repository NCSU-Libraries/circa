CircaCtrl.prototype.applyLocationFunctions = function(scope) {

  var _this = this;

  scope.showLocation = function(locationId) {
    _this.showLocation(locationId);
  }

  scope.editLocation = function(locationId) {
    _this.editLocation(locationId);
  }

  console.log('locations');

}


CircaCtrl.prototype.showLocation = function(locationId) {
  this.goto('locations/' + locationId);
}


CircaCtrl.prototype.editLocation = function(locationId) {
  this.goto('locations/' + locationId + '/edit');
}


CircaCtrl.prototype.getLocation = function(scope, id, callback) {
  var path = '/locations/' + id;
  var _this = this;
  this.apiRequests.get(path).then(function(response) {
    if (response.status == 200) {
      scope.location = response.data['location'];
      _this.commonUtils.executeCallback(callback, scope);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
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
