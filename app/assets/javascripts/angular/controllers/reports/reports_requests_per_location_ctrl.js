var ReportsRequestsPerLocationCtrl = function($scope, $route, $routeParams, $location, $window, $modal, $filter, apiRequests, sessionCache, commonUtils, formUtils) {

  ReportsCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, $filter, apiRequests, sessionCache, commonUtils, formUtils);

  this.getRequestsByLocation();

  this.updateReport = function() {
    this.getRequestsByLocation();
  }
}

ReportsRequestsPerLocationCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', '$filter', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];

ReportsRequestsPerLocationCtrl.prototype = Object.create(ReportsCtrl.prototype);

circaControllers.controller('ReportsRequestsPerLocationCtrl', ReportsRequestsPerLocationCtrl);

ReportsRequestsPerLocationCtrl.prototype.getRequestsByLocation = function() {
  var _this = this;
  this.loading = true;
  var config = this.generateRequestConfig();
  path = '/reports/item_requests_per_location';
  this.apiRequests.get(path, config).then(function(response) {
    _this.loading = false;
    _this.requestsPerLocation = response.data;
  });
}
