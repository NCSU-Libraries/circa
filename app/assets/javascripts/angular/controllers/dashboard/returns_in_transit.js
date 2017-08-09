// extends DashboardCtrl

DashboardCtrl.prototype.filterReturnsInTransitByFacility = function(facility) {
  var _this = this;
  var filters = { permanent_location_facility: facility };
  _this.getReturnsInTransit(filters);
}


DashboardCtrl.prototype.getReturnsInTransit = function(filters) {

  this.dashbaordLoading = true;

  var _this = this;
  var path = '/items/returns_in_transit';
  var config = { params: {} }
  this.filters = filters || {};
  if (filters) {
    for (var key in filters) {
      if (filters.hasOwnProperty(key)) {
        config.params['filters[' + key + ']'] = filters[key]
      }
    }
  }

  this.apiRequests.get(path, config).then(function(response) {
    _this.dashbaordLoading = false;
    if (response.status == 200) {
      _this.returnsInTransit = response.data;

      console.log(_this.returnsInTransit );

    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.flash = response.data['error']['detail'];
    }
  });
}


DashboardCtrl.prototype.openReturnsList = function() {
  var url = this.rootPath() + '/items/returns_list';
  var q = [];
  if (this.filters) {
    for (var key in this.filters) {
      if (this.filters.hasOwnProperty(key)) {
        qComponent = 'filters[' + key + ']=' + encodeURIComponent(this.filters[key]);
        q.push(qComponent);
      }
    }
  }
  if (q.length > 0) {
    url = url + '?' + q.join('&');
  }

  this.window.open(url,'_blank');
}
