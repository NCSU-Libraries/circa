var ReportsTransfersPerLocationCtrl = function($scope, $route, $routeParams, $location, $window, $modal, $filter, apiRequests, sessionCache, commonUtils, formUtils) {

  ReportsCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, $filter, apiRequests, sessionCache, commonUtils, formUtils);

  console.log(this.dateParams);

  this.getTransfersPerLocationByDate();

  this.updateReport = function() {
    this.getTransfersPerLocationByDate();
  }

}

ReportsTransfersPerLocationCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', '$filter', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];

ReportsTransfersPerLocationCtrl.prototype = Object.create(ReportsCtrl.prototype);

circaControllers.controller('ReportsTransfersPerLocationCtrl', ReportsTransfersPerLocationCtrl);

ReportsTransfersPerLocationCtrl.prototype.getTransfersPerLocationByDate = function() {
  var _this = this;
  this.loading = true;
  var config = this.generateRequestConfig();
  path = '/reports/item_transfers_per_location';
  this.apiRequests.get(path, config).then(function(response) {
    _this.loading = false;
    _this.transfersPerLocation = response.data;
  });
}
