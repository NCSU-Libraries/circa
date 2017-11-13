OrdersCtrl.prototype.setAppliedFilters = function(scope) {
  scope.filterConfig.appliedFilters = {};
  var filters = scope.filterConfig.filters;
  var skipFilters = ['access_date_start', 'access_date_end'];
  for (var f in filters) {
    if (skipFilters.indexOf(f) < 0) {
      scope.filterConfig.appliedFilters[f] = filters[f];
    }
  }
  // deal with dates
  var fromDate = scope.filterConfig.options['access_date_from'];
  var toDate = scope.filterConfig.options['access_date_to'];
  var dateValue = null;
  if (fromDate && toDate) {
    dateValue = 'between ' + fromDate + ' and ' + toDate;
  }
  else if (fromDate) {
    dateValue = 'after ' + fromDate;
  }
  else if (toDate) {
    dateValue = 'before ' + toDate;
  }
  if (dateValue) {
    scope.filterConfig.appliedFilters['access_dates'] = dateValue;
  }
  scope.filterConfig.filtersApplied = Object.keys(scope.filterConfig.appliedFilters).length > 0 ? true : false;
}


OrdersCtrl.prototype.setDateFilter = function(scope, field) {

  var fromDate = scope.filterConfig.options['access_date_from'];
  var toDate = scope.filterConfig.options['access_date_to'];

  // Handle empty strings
  if (fromDate && fromDate.length == 0) {
    fromDate = null;
    scope.filterConfig.options['access_date_from'] = null;
  }
  if (toDate && toDate.length == 0) {
    toDate = null;
    scope.filterConfig.options['access_date_to'] = null;
  }

  if (fromDate && toDate) {
    var rangeValue =  '[' + fromDate + ' TO ' + toDate + ']';
    scope.filterConfig.filters['access_date_start'] = rangeValue;
    scope.filterConfig.filters['access_date_end'] = rangeValue;
  }
  else if (fromDate && !toDate) {
    var rangeValue =  '[' + fromDate + ' TO *]';
    scope.filterConfig.filters['access_date_start'] = rangeValue;
    delete scope.filterConfig.filters['access_date_end'];
  }
  else if (!fromDate && toDate) {
    var rangeValue =  '[* TO ' + toDate + ']';
    scope.filterConfig.filters['access_date_end'] = rangeValue;
    delete scope.filterConfig.filters['access_date_start'];
  }
  else {
    delete scope.filterConfig.filters['access_date_start'];
    delete scope.filterConfig.filters['access_date_end'];
  }
}
