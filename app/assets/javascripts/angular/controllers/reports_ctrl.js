var ReportsCtrl = function($scope, $route, $routeParams, $location, $window, $modal, $filter, apiRequests, sessionCache, commonUtils, formUtils) {

  this.reportsList = [
    { title: "Item requests per resource/collection", path: "reports/requests_per_resource"},
    { title: "Item requests per location", path: "reports/requests_per_location"},
    { title: "Item transfers per location", path: "reports/transfers_per_location"}
  ]

  CircaCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  this.filter = $filter;
  this.defaultLimit = 5;
  this.limit = this.defaultLimit;
  this.dateUnitOptions = ['day','week','month'];
  this.showDateUnitOptions = true;
  this.initializeDateParams();

  // Each inheritor must define updateReport separately to override this default nothing
  this.updateReport = function() {
    return null;
  }

}

ReportsCtrl.$inject = [ '$scope', '$route', '$routeParams', '$location', '$window', '$modal', '$filter', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils' ];

ReportsCtrl.prototype = Object.create(CircaCtrl.prototype);

circaControllers.controller('ReportsCtrl', ReportsCtrl);


ReportsCtrl.prototype.showAll = function() {
  this.limit = this.requestsPerResource.total_resources;
}


ReportsCtrl.prototype.showLimit = function() {
  this.limit = this.defaultLimit;
}


ReportsCtrl.prototype.initializeDateParams = function() {
  console.log('initializeDateParams');
  var today = Date.now();
  var dateEnd = new Date(today);
  var dateMonth = dateEnd.getMonth();
  // var dateStartMonth = (dateMonth > 0) ? (dateMonth - 1) : 11;
  // var dateStart = new Date(today);
  // dateStart.setMonth(dateStartMonth);

  var dateStartMonth = null;
  var dateStart = null;

  this.dateParams = {
    dateUnit: 'month',
    // dateStart: this.filter('date')(dateStart, 'yyyy-MM-dd'),
    dateStart: null,
    dateEnd: this.filter('date')(dateEnd, 'yyyy-MM-dd')
  };
}


ReportsCtrl.prototype.changeDateUnit = function(dateUnit) {
  this.dateParams.dateUnit = dateUnit;
  this.updateReport();
}


ReportsCtrl.prototype.generateRequestConfig = function() {
  return {
    params: {
      date_unit: this.dateParams.dateUnit,
      date_start: this.dateParams.dateStart,
      date_end: this.dateParams.dateEnd
    }
  }
}


ReportsCtrl.prototype.dateColumnHeading = function() {
  var heading = '';
  switch(this.dateParams.dateUnit) {
    case 'day':
      heading = 'Date';
      break;
    case 'month':
      heading = 'Month';
      break;
    case 'week':
      heading = 'Week of';
      break;
  }
  return heading;
}
