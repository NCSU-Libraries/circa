var ReportsResourceRequestsCtrl = function($scope, $route, $routeParams, $location, $window, $modal, $filter, apiRequests, sessionCache, commonUtils, formUtils) {

  ReportsCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, $filter, apiRequests, sessionCache, commonUtils, formUtils);

  this.getRequestsPerResource();
  this.defaultLimit = 5;
  this.limit = this.defaultLimit;
  this.showDateUnitOptions = false;

  this.updateReport = function() {
    this.getRequestsPerResource();
  }
}

ReportsResourceRequestsCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', '$filter', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];

ReportsResourceRequestsCtrl.prototype = Object.create(ReportsCtrl.prototype);

circaControllers.controller('ReportsResourceRequestsCtrl', ReportsResourceRequestsCtrl);

ReportsResourceRequestsCtrl.prototype.getRequestsPerResource = function() {
  var _this = this;
  this.loading = true;
  var config = this.generateRequestConfig();
  path = '/reports/item_requests_per_resource';
  this.apiRequests.get(path, config).then(function(response) {
    _this.loading = false;
    _this.requestsPerResource = response.data;
  });
}
