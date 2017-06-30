//  - inherits from DashboardCtrl

var PendingTransfersCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  DashboardCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  // set pendingItemTransfers
  this.getPendingItemTransfers();
}

PendingTransfersCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
PendingTransfersCtrl.prototype = Object.create(DashboardCtrl.prototype);
circaControllers.controller('PendingTransfersCtrl', PendingTransfersCtrl);


PendingTransfersCtrl.prototype.filterByFacility = function(facility) {
  var _this = this;
  var filters = { permanent_location_facility: facility };
  _this.getPendingItemTransfers(filters);
}


PendingTransfersCtrl.prototype.getPendingItemTransfers = function(filters) {

  this.loading = true;

  var _this = this;
  var path = '/items/pending_transfers';
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
    _this.loading = false;

    if (response.status == 200) {
      _this.pendingItemTransfers = response.data;
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.flash = response.data['error']['detail'];
    }
  });
}


PendingTransfersCtrl.prototype.openPullList = function() {
  var url = this.rootPath() + '/items/transfer_list';
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
