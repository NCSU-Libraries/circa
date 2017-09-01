// DashboardCtrl  - inherits from CircaCtrl

var DashboardCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  CircaCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  this.active = 'pendingTransfers'
  this.getPendingItemTransfers();

}

DashboardCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
DashboardCtrl.prototype = Object.create(CircaCtrl.prototype);

circaControllers.controller('DashboardCtrl', DashboardCtrl);


DashboardCtrl.prototype.setActive = function(dashboardName) {
  this.active = dashboardName;
  var _this = this;
  switch (dashboardName) {
  case 'pendingTransfers':
    this.getPendingItemTransfers();
    break;
  case 'returnsInTransit':
    this.getReturnsInTransit();
    break;
  case 'itemsInTransitForUse':
    this.getItemsInTransitForUse();
    break;
  case 'courseReserves':
    this.getCourseReserves();
    break;
  case 'digitalObjectRequests':
    this.getDigitalObjectRequests();
    break;
  }
}
