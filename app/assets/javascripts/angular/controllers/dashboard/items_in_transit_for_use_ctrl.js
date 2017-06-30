// ItemsInTransitForUseCtrl  - inherits from DashboardCtrl

var ItemsInTransitForUseCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  DashboardCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  this.getDashboardRecords = function(filters) {
    this.getItemsInTransitForUse(filters);
  }

  // set pendingItemTransfers
  this.getItemsInTransitForUse();
}

ItemsInTransitForUseCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
ItemsInTransitForUseCtrl.prototype = Object.create(DashboardCtrl.prototype);
circaControllers.controller('ItemsInTransitForUseCtrl', ItemsInTransitForUseCtrl);


ItemsInTransitForUseCtrl.prototype.filterByLocation = function(location) {
  var _this = this;
  var filters = { location: location };
  _this.getItemsInTransitForUse(filters);
}


ItemsInTransitForUseCtrl.prototype.getItemsInTransitForUse = function(filters) {

  this.loading = true;

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
    _this.loading = false;
    if (response.status == 200) {
      _this.itemsInTransitForUse = response.data;
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.flash = response.data['error']['detail'];
    }
  });
}


ItemsInTransitForUseCtrl.prototype.openList = function() {
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
