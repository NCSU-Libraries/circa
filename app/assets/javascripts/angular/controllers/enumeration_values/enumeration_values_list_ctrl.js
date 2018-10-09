// Enumeration values list

var EnumerationValuesListCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  EnumerationValuesCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  this.enumerationName = $routeParams.enumerationName;

  this.getEnumerationValuesList($routeParams.enumerationName);

}

EnumerationValuesListCtrl.prototype = Object.create(EnumerationValuesCtrl.prototype);
EnumerationValuesListCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('EnumerationValuesListCtrl', EnumerationValuesListCtrl);
