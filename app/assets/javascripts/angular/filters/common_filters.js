'use strict';

/* Filters */

var commonFilters = angular.module('commonFilters', []);


commonFilters.filter('removeUnderscores', function () {
  return function (value) {
    if (value) {
      return value.replace(/_/g, ' ');
    }
  }
});


commonFilters.filter('cssClassName', function () {
  return function (value) {
    if (value) {
      return value.replace(/[^A-Za-z0-9]/g, '-');
    }
  }
});


commonFilters.filter('capitalize', function () {
  return function (value) {
    if (value && typeof value === 'string') {
      return value.charAt(0).toUpperCase() + value.slice(1);
    }
  }
});


commonFilters.filter('booleanString', function () {
  return function (value) {
    if (value) {
      if (value == '1' || value == 1) {
        return 'true';
      }
      else if (value == '0' || value == 0) {
        return 'false';
      }
      else {
        return value;
      }
    }
  }
});
