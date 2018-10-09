// Settings

var SettingsCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  this.section = 'settings';

  CircaCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

}

SettingsCtrl.prototype = Object.create(CircaCtrl.prototype);
SettingsCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('SettingsCtrl', SettingsCtrl);
