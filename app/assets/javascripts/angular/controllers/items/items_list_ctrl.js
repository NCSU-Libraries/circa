// ItemsListCtrl - For list view, inherits from ItemsCtrl

var ItemsListCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  ItemsCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  // $scope.getItems = function(page) {
  //   this.getItems($scope, page);
  // }

  this.processListParams($scope);
  this.getItems($scope, $scope.page);
}

ItemsListCtrl.prototype = Object.create(ItemsCtrl.prototype);
ItemsListCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('ItemsListCtrl', ItemsListCtrl);
