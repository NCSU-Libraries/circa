// ReturnsInTransitCtrl - inherits from DashboardCtrl

var DigitalObjectRequestsCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  DashboardCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  // set pendingItemTransfers
  this.getDigitalObjectRequests();
}

DigitalObjectRequestsCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
DigitalObjectRequestsCtrl.prototype = Object.create(DashboardCtrl.prototype);
circaControllers.controller('DigitalObjectRequestsCtrl', DigitalObjectRequestsCtrl);

DigitalObjectRequestsCtrl.prototype.getDigitalObjectRequests = function() {
  this.loading = true;
  var _this = this;
  var path = '/items/digital_object_requests';
  this.apiRequests.get(path).then(function(response) {
    _this.loading = false;
    if (response.status == 200) {
      _this.digitalObjectRequests = response.data;
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.flash = response.data['error']['detail'];
    }
  });
}
