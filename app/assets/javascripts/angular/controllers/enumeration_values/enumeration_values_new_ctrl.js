// Enumeration values new

var EnumerationValuesNewCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  EnumerationValuesCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  this.enumerationValue = {
    value: '',
    value_short: '',
    enumeration_name: $routeParams.enumerationName
  };

  this.enumerationName = $routeParams.enumerationName;

  this.mode = 'new';

}

EnumerationValuesNewCtrl.prototype = Object.create(EnumerationValuesCtrl.prototype);
EnumerationValuesNewCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('EnumerationValuesNewCtrl', EnumerationValuesNewCtrl);
