// Enumeration values list

var EnumerationValuesMergeCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {

  EnumerationValuesCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  this.getEnumerationValue($scope, $routeParams.enumerationValueId);

  var setMergeIntoValues = function(scope, data) {
    scope.mergeIntoValues = [];
    for (var i = 0; i < scope.enumerationValuesList.length; i++) {
      var value = scope.enumerationValuesList[i];
      if (value['id'] != $routeParams.enumerationValueId) {
        scope.mergeIntoValues.push(value);
      }
    }
  }

  this.getEnumerationValuesList($scope, $routeParams.enumerationName, setMergeIntoValues);

  $scope.mode = 'merge';

}

EnumerationValuesMergeCtrl.prototype = Object.create(EnumerationValuesCtrl.prototype);
EnumerationValuesMergeCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('EnumerationValuesMergeCtrl', EnumerationValuesMergeCtrl);
