// DashboardCtrl  - inherits from CircaCtrl

var DashboardCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {
  CircaCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  this.activeDashboard = 'pendingTransfers'
  this.getPendingItemTransfers();
}

DashboardCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
DashboardCtrl.prototype = Object.create(CircaCtrl.prototype);

circaControllers.controller('DashboardCtrl', DashboardCtrl);

DashboardCtrl.prototype.setActiveDashboard = function(dashboardName) {
  this.activeDashboard = dashboardName;

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
