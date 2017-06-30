// DashboardCtrl  - inherits from CircaCtrl

var DashboardCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  CircaCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  // Each inheritor controller must define this.getDashboardRecords
  // this.getDashboardRecords = function() { return null; }
  // this.getDashboardRecords();
}

DashboardCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
DashboardCtrl.prototype = Object.create(CircaCtrl.prototype);
circaControllers.controller('DashboardCtrl', DashboardCtrl);

// DashboardCtrl.prototype.filterByFacility = function(facility) {
//   var _this = this;
//   var filters = { permanent_location_facility: facility };
//   _this.getDashboardRecords();
// }
