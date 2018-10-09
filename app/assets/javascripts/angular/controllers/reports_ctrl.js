var ReportsCtrl = function($route, $routeParams, $location, $window, $filter, apiRequests, sessionCache, commonUtils, formUtils) {

  CircaCtrl.call(this, $route, $routeParams, $location, $window,
      apiRequests, sessionCache, commonUtils, formUtils);

  this.section = 'reports';

  this.filter = $filter;

  if (!$routeParams.reportName) {
    this.initializeReportsList();
  }
  else {
    this.reportName = $routeParams.reportName;
    this.initializeReport();
  }
}

ReportsCtrl.$inject = [ '$route', '$routeParams', '$location',
    '$window', '$filter', 'apiRequests', 'sessionCache',
    'commonUtils', 'formUtils' ];

ReportsCtrl.prototype = Object.create(CircaCtrl.prototype);

circaControllers.controller('ReportsCtrl', ReportsCtrl);


ReportsCtrl.prototype.initializeReportsList = function() {
  this.reportsList = [
    { title: "Item requests per resource/collection", path: "reports/requests_per_resource" },
    { title: "Item requests per location", path: "reports/requests_per_location" },
    { title: "Item transfers per location", path: "reports/transfers_per_location" },
    { title: "Researchers per type", path: "reports/researchers_per_type" },
    { title: "Orders per researcher type", path: "reports/orders_per_researcher_type" },
    { title: "Unique researcher visits", path: "reports/unique_visits" }
  ]
  this.template = 'reports/list';
  this.pageTitle = 'Reports';
}


ReportsCtrl.prototype.initializeReport = function() {
  this.defaultLimit = 5;
  this.limit = this.defaultLimit;
  this.dateUnitOptions = ['day','week','month'];
  this.initializeDateParams();

  switch (this.reportName) {
    case 'orders_per_researcher_type':
      this.template = 'reports/orders_per_researcher_type';
      this.pageTitle = 'Orders per researcher type';
      this.apiPath = '/reports/orders_per_researcher_type'
      break;
    case 'requests_per_location':
      this.template = 'reports/requests_per_location';
      this.pageTitle = 'Item requests per location';
      this.apiPath = '/reports/item_requests_per_location';
      this.showDateUnitOptions = true;
      break;
    case 'researchers_per_type':
      this.template = 'reports/researchers_per_type';
      this.pageTitle = 'Researchers per type';
      this.apiPath = '/reports/researchers_per_type';
      break;
    case 'requests_per_resource':
      this.template = 'reports/requests_per_resource';
      this.pageTitle = 'Item requests per resource/collection';
      this.apiPath = '/reports/item_requests_per_resource';
      break;
    case 'transfers_per_location':
      this.template = 'reports/transfers_per_location';
      this.pageTitle = 'Item transfers per location';
      this.apiPath = '/reports/item_transfers_per_location';
      this.showDateUnitOptions = true;
      break;
    case 'unique_visits':
      this.template = 'reports/unique_visits';
      this.pageTitle = 'Unique visits by on-site researchers';
      this.apiPath = '/reports/unique_visits';
      this.showDateUnitOptions = true;
      break;
  }
  this.getReportData();
}


ReportsCtrl.prototype.initializeDateParams = function() {
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


ReportsCtrl.prototype.resetDateFilter = function() {
  this.initializeDateParams();
  this.getReportData();
}


ReportsCtrl.prototype.showAll = function() {
  this.limit = this.requestsPerResource.total_records;
}


ReportsCtrl.prototype.showLimit = function() {
  this.limit = this.defaultLimit;
}


ReportsCtrl.prototype.changeDateUnit = function(dateUnit) {
  this.dateParams.dateUnit = dateUnit;
  this.getReportData();
}


ReportsCtrl.prototype.generateRequestConfig = function() {
  if (!this.dateParams) {
    return null;
  }
  else {
    return {
      params: {
        date_unit: this.dateParams.dateUnit,
        date_start: this.dateParams.dateStart,
        date_end: this.dateParams.dateEnd
      }
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


ReportsCtrl.prototype.getReportData = function() {
  var _this = this;
  this.loading = true;
  var config = this.generateRequestConfig();

  this.apiRequests.get(this.apiPath, config).then(function(response) {
    _this.loading = false;
    _this.reportData = response.data;
  });
}
