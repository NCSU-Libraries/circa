OrdersCtrl.prototype.applyArchivesSpaceFunctions = function(scope) {

  var _this = this;

  scope.addItemsFromArchivesSpace = function() {
    _this.addItemsFromArchivesSpace(scope);
  }

}


// Initialize object used to manage selections from ArchivesSpace
OrdersCtrl.prototype.initializeArchivesSpaceRecordSelect = function(scope) {
  scope.archivesSpaceRecordSelect = {
    'uri': '', 'loading': false, 'alert': null, 'digitalObject': false
  };
}


OrdersCtrl.prototype.orderArchivesSpaceRecords = function (scope) {
  var records = [];
  if ((scope.order) && scope.order['item_orders']) {
    scope.order['item_orders'].forEach(function(orderItem) {
      records = records.concat(orderItem['archivesspace_uri']);
    });
  }
  return records;
}


OrdersCtrl.prototype.addItemsFromArchivesSpace = function(scope, callback) {
  var _this = this;

  var uri = scope.archivesSpaceRecordSelect['uri'];

  scope.archivesSpaceRecordSelect['loading'] = true;
  scope.archivesSpaceRecordSelect['alert'] = null;

  var addArchivesSpaceUriToItemOrder = function(itemId, uri) {
    var targetIndex = _this.getItemOrderIndex(scope.order['item_orders'], itemId);
    if (targetIndex) {
      scope.order['item_orders'][targetIndex]['archivesspace_uri'].push(uri);
    }
  }


  if (_this.orderArchivesSpaceRecords(scope).indexOf(uri) >= 0) {
    _this.initializeArchivesSpaceRecordSelect(scope);
    scope.archivesSpaceRecordSelect['alert'] = 'The ArchivesSpace record at ' + uri + ' is already included in this order.';
  }
  else {
    _this.apiRequests.post('items/create_from_archivesspace', { 'archivesspace_uri': scope.archivesSpaceRecordSelect['uri'], 'digital_object': scope.archivesSpaceRecordSelect['digitalObject'] } ).then(function(response) {

      scope.archivesSpaceRecordSelect['loading'] = false;

      if (response.status == 200) {
        if (Array.isArray(response.data['items'])) {
          $.each(response.data['items'], function(index, item) {
            if (scope.itemIds.indexOf(item['id']) < 0) {
              scope.itemIds.push(item['id']);
              item['archivesspace_uri'] = uri;

              // REMOVED AFTER items REMOVED FROM order
              // scope.order['items'].push(item);

              // _this.addItemOrder(scope, item['id'], scope.archivesSpaceRecordSelect['uri']);
              _this.addItemOrder(scope, item, scope.archivesSpaceRecordSelect['uri']);
            }
            else {
              scope.archivesSpaceRecordSelect['alert'] = "One or more containers corresponding to the ArchivesSpace record is already included in the order. The ArchivesSpace URI entered will be added for reference.";
              addArchivesSpaceUriToItemOrder(item['id'], scope.archivesSpaceRecordSelect['uri']);
            }
          });
          scope.archivesSpaceRecordSelect['uri'] = null;
          scope.archivesSpaceRecordSelect['digitalObject'] = false;
          _this.commonUtils.executeCallback(callback, response.data);
        }
        else {
          _this.initializeArchivesSpaceRecordSelect(scope);
          scope.archivesSpaceRecordSelect['alert'] = 'The ArchivesSpace record at ' + uri + ' has no linked containers and cannot be ordered.';
        }
      }
      else {
        _this.initializeArchivesSpaceRecordSelect(scope);
        scope.archivesSpaceRecordSelect['alert'] = response.data['error']['detail'];
      }
    });
  }

}
