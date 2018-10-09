// ItemsListCtrl - For list view, inherits from ItemsCtrl

var ItemsListCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  ItemsCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  this.processListParams();
  this.getItems(this.page);
  this.deletedRecordFlash('item');
}

ItemsListCtrl.prototype = Object.create(ItemsCtrl.prototype);
ItemsListCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('ItemsListCtrl', ItemsListCtrl);
