// extends from DashboardCtrl

DashboardCtrl.prototype.filterItemsInTransitForUseByLocation = function(location) {
  var _this = this;
  var filters = { location: location };
  _this.getItemsInTransitForUse(filters);
}


DashboardCtrl.prototype.getItemsInTransitForUse = function(filters) {
  this.dashbaordLoading = true;

  var _this = this;
  var path = '/items/items_in_transit_for_use';
  var config = { params: {} };

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

      console.log(response.data);

      _this.itemsInTransitForUse = response.data;
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.flash = response.data['error']['detail'];
    }
  });
}


DashboardCtrl.prototype.openList = function() {
  var url = this.rootPath() + '/items/items_in_transit_for_use_list';
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
