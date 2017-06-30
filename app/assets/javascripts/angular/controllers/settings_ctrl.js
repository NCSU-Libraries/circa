// Settings

var SettingsCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {

  $scope.section = 'settings';

  CircaCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

}

SettingsCtrl.prototype = Object.create(CircaCtrl.prototype);
SettingsCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('SettingsCtrl', SettingsCtrl);
