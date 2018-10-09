// Enumeration values list

var EnumerationValuesMergeCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  EnumerationValuesCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  this.getEnumerationValue($routeParams.enumerationValueId);

  var setMergeIntoValues = function(data) {
    this.mergeIntoValues = [];
    for (var i = 0; i < this.enumerationValuesList.length; i++) {
      var value = this.enumerationValuesList[i];
      if (value['id'] != $routeParams.enumerationValueId) {
        this.mergeIntoValues.push(value);
      }
    }
  }

  this.getEnumerationValuesList($routeParams.enumerationName, setMergeIntoValues);

  this.mode = 'merge';
}

EnumerationValuesMergeCtrl.prototype = Object.create(EnumerationValuesCtrl.prototype);
EnumerationValuesMergeCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('EnumerationValuesMergeCtrl', EnumerationValuesMergeCtrl);
