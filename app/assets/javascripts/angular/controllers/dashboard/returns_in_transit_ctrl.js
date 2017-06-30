// ReturnsInTransitCtrl - inherits from DashboardCtrl

var ReturnsInTransitCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  DashboardCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  // set pendingItemTransfers
  this.getReturnsInTransit();
}

ReturnsInTransitCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
ReturnsInTransitCtrl.prototype = Object.create(DashboardCtrl.prototype);
circaControllers.controller('ReturnsInTransitCtrl', ReturnsInTransitCtrl);


ReturnsInTransitCtrl.prototype.filterByFacility = function(facility) {
  var _this = this;
  var filters = { permanent_location_facility: facility };
  _this.getReturnsInTransit(filters);
}


ReturnsInTransitCtrl.prototype.getReturnsInTransit = function(filters) {

  this.loading = true;

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
    _this.loading = false;
    if (response.status == 200) {
      _this.returnsInTransit = response.data;
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.flash = response.data['error']['detail'];
    }
  });
}


ReturnsInTransitCtrl.prototype.openReturnsList = function() {
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
