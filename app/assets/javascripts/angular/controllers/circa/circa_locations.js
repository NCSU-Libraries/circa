CircaCtrl.prototype.showLocation = function(locationId) {
  this.goto('locations/' + locationId);
}


CircaCtrl.prototype.editLocation = function(locationId) {
  this.goto('locations/' + locationId + '/edit');
}


CircaCtrl.prototype.getLocation = function(id, callback) {
  var path = '/locations/' + id;
  var _this = this;
  this.apiRequests.get(path).then(function(response) {
    if (response.status == 200) {
      _this.circaLocation = response.data['location'];
      _this.commonUtils.executeCallback(callback);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.flash = response.data['error']['detail'];
    }
  });
}


CircaCtrl.prototype.getLocations = function(page, sort) {
  var path = '/locations';
  var _this = this;

  page = page ? page : 1;
  if (typeof sort !== 'undefined') {
    path = path + '?sort=' + sort;
  }
  this.apiRequests.getPage(path,page).then(function(response) {
    if (response.status == 200) {
      _this.locations = response.data['locations'];
      var paginationParams = _this.commonUtils.paginationParams(response.data['meta']['pagination']);
      _this.commonUtils.objectMerge(paginationParams);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.flash = response.data['error']['detail'];
    }
  });
}
