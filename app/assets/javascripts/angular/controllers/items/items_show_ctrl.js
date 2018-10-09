// ItemsShowCtrl - For list view, inherits from ItemsCtrl

var ItemsShowCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {
  ItemsCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);
  this.getItem($routeParams.itemId);
}

ItemsShowCtrl.prototype = Object.create(ItemsCtrl.prototype);
ItemsShowCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('ItemsShowCtrl', ItemsShowCtrl);
