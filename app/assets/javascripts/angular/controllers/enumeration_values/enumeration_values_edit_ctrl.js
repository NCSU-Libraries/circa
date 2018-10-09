// Enumeration values list

var EnumerationValuesEditCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  EnumerationValuesCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  this.getEnumerationValue($routeParams.enumerationValueId);

  this.mode = 'edit';

}

EnumerationValuesEditCtrl.prototype = Object.create(EnumerationValuesCtrl.prototype);
EnumerationValuesEditCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('EnumerationValuesEditCtrl', EnumerationValuesEditCtrl);
