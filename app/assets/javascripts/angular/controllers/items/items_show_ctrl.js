// ItemsShowCtrl - For list view, inherits from ItemsCtrl

var ItemsShowCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  ItemsCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);
  this.getItem($scope, $routeParams.itemId);
}

ItemsShowCtrl.prototype = Object.create(ItemsCtrl.prototype);
ItemsShowCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('ItemsShowCtrl', ItemsShowCtrl);
