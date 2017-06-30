var ItemsCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {

  var _this = this;

  $scope.section = 'items';

  CircaCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  this.apiRequests = apiRequests;
  this.location = $location;
  this.window = $window;

  // $scope.sort = 'resource_title asc';
  // $scope.sortOrder = 'asc';

  $scope.getItemHistory = function(id) {
    _this.getItemHistory($scope, id);
  }

  this.initializeFilterConfig($scope);

  $scope.confirmObsolete = function(itemId) {
    _this.confirmObsolete($scope, itemId)
  }

  $scope.updateItemFromSource = function(itemId) {
    _this.updateItemFromSource($scope, itemId);
  }

}

ItemsCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];

ItemsCtrl.prototype = Object.create(CircaCtrl.prototype);

circaControllers.controller('ItemsCtrl', ItemsCtrl);


ItemsCtrl.prototype.getPage = function(scope, page) {
  this.getItems(scope, page);
}


ItemsCtrl.prototype.getItems = function(scope, page) {

  console.log(page);

  scope.loading = true;
  var path = '/items';
  var _this = this;
  page = page ? page : 1;
  scope.page = page;

  var config = this.listRequestConfig(scope);

  this.updateLocationQueryParams(config['params']);

  this.apiRequests.getPage(path, page, config).then(function(response) {
    scope.loading = false;
    if (response.status == 200) {
      scope.items = response.data['items'];
      var paginationParams = _this.commonUtils.paginationParams(response.data['meta']['pagination']);

      console.log(paginationParams);

      _this.commonUtils.objectMerge(scope, paginationParams);
    }
  });
}


ItemsCtrl.prototype.getItem = function(scope, id, callback) {
  var path = '/items/' + id;
  var _this = this;
  this.apiRequests.get(path).then(function(response) {
    if (response.status == 200) {
      scope.item = response.data['item'];
      _this.commonUtils.executeCallback(callback, scope);
    }
    else {
      scope.error = response.data['error'];
    }
  });
}


ItemsCtrl.prototype.getItemHistory = function(scope, id, callback) {
  var path = '/items/' + id + '/history';
  var _this = this;
  this.apiRequests.get(path).then(function(response) {
    if (response.status == 200) {
      if (scope['item']) {
        scope['item']['movement_history'] = response.data['item']['movement_history'];
      }
      else {
        scope.item = response.data['item'];
      }
      _this.commonUtils.executeCallback(callback, scope);
    }
    else {
      scope.error = response.data['error'];
    }
  });
}


ItemsCtrl.prototype.confirmObsolete = function(scope, itemId) {
  var _this = this;

  var modalInstance = _this.modal.open({
    templateUrl: _this.templateUrl('items/obsolete'),
    controller: 'CircaModalInstanceCtrl',
    resolve: {
      resolved: function() {
        return {
          itemId: itemId
        }
      }
    }
  });

  modalInstance.result.then(function (result) {
    _this.obsolete(scope, itemId);
  }, function () {
    console.log('Modal dismissed at: ' + new Date());
  });
}


ItemsCtrl.prototype.obsolete = function(scope, itemId) {
  scope.loading = true;
  var path = '/items/' + itemId + '/obsolete';
  var _this = this;
  this.apiRequests.put(path).then(function(response) {

    console.log(response);

    scope.loading = false;
    if ((response.status - 200) < 100) {
      // var message = "Item " + itemId + " has been marked as obsolete";
      // _this.goto('/items', true, message);
      scope.item = response.data['item'];
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
}


ItemsCtrl.prototype.updateItemFromSource = function(scope, itemId) {
  scope.loading = true;
  var path = '/items/' + itemId + '/update_from_source';
  var _this = this;
  this.apiRequests.get(path).then(function(response) {
    scope.loading = false;
    if (response.status == 200) {
      scope.item = response.data['item'];
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
}

