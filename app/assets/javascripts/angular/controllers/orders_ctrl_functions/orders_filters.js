OrdersCtrl.prototype.setAppliedFilters = function() {
  this.filterConfig.appliedFilters = {};
  var filters = this.filterConfig.filters;
  var skipFilters = ['access_date_start', 'access_date_end'];
  for (var f in filters) {
    if (skipFilters.indexOf(f) < 0) {
      this.filterConfig.appliedFilters[f] = filters[f];
    }
  }
  // deal with dates
  var fromDate = this.filterConfig.options['access_date_from'];
  var toDate = this.filterConfig.options['access_date_to'];
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
    this.filterConfig.appliedFilters['access_dates'] = dateValue;
  }
  this.filterConfig.filtersApplied = Object.keys(this.filterConfig.appliedFilters).length > 0 ? true : false;
}


OrdersCtrl.prototype.setDateFilter = function(field) {

  var fromDate = this.filterConfig.options['access_date_from'];
  var toDate = this.filterConfig.options['access_date_to'];

  // Handle empty strings
  if (fromDate && fromDate.length == 0) {
    fromDate = null;
    this.filterConfig.options['access_date_from'] = null;
  }

  if (toDate && toDate.length == 0) {
    toDate = null;
    this.filterConfig.options['access_date_to'] = null;
  }

  if (fromDate && toDate) {
    var rangeValue =  '[' + fromDate + ' TO ' + toDate + ']';
    this.filterConfig.filters['access_date_start'] = rangeValue;
    this.filterConfig.filters['access_date_end'] = rangeValue;
  }
  else if (fromDate && !toDate) {
    var rangeValue =  '[' + fromDate + ' TO *]';
    this.filterConfig.filters['access_date_start'] = rangeValue;
    delete this.filterConfig.filters['access_date_end'];
  }
  else if (!fromDate && toDate) {
    var rangeValue =  '[* TO ' + toDate + ']';
    this.filterConfig.filters['access_date_end'] = rangeValue;
    delete this.filterConfig.filters['access_date_start'];
  }
  else {
    delete this.filterConfig.filters['access_date_start'];
    delete this.filterConfig.filters['access_date_end'];
  }
}
