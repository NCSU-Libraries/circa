// Initialize object used to manage selections from ArchivesSpace
OrdersCtrl.prototype.initializeArchivesSpaceRecordSelect = function() {
  this.archivesSpaceRecordSelect = {
    uri: '',
    loading: false,
    alert: null,
    digitalObject: false,
    show: false
  };
  this.showItemSelector = false;
}


OrdersCtrl.prototype.showArchivesSpaceRecordSelector = function() {
  this.showItemSelector = 'archivesspace';
}


OrdersCtrl.prototype.orderArchivesSpaceRecords = function () {
  var records = [];
  if ((this.order) && this.order['item_orders']) {
    this.order['item_orders'].forEach(function(orderItem) {
      records = records.concat(orderItem['archivesspace_uri']);
    });
  }
  return records;
}


OrdersCtrl.prototype.addItemsFromArchivesSpace = function(callback) {
  var _this = this;

  var uri = this.archivesSpaceRecordSelect['uri'];

  this.archivesSpaceRecordSelect['loading'] = true;
  this.archivesSpaceRecordSelect['alert'] = null;

  var addArchivesSpaceUriToItemOrder = function(itemId, uri) {
    var targetIndex = _this.getItemOrderIndex(_this.order['item_orders'], itemId);
    if (targetIndex) {
      _this.order['item_orders'][targetIndex]['archivesspace_uri'].push(uri);
    }
  }


  if (_this.orderArchivesSpaceRecords().indexOf(uri) >= 0) {
    _this.initializeArchivesSpaceRecordSelect();
    _this.archivesSpaceRecordSelect['alert'] = 'The ArchivesSpace record at ' + uri + ' is already included in this order.';
  }
  else {
    _this.apiRequests.post('items/create_from_archivesspace', { 'archivesspace_uri': _this.archivesSpaceRecordSelect['uri'], 'digital_object': _this.archivesSpaceRecordSelect['digitalObject'] } ).then(function(response) {

      _this.archivesSpaceRecordSelect['loading'] = false;

      if (response.status == 200) {
        if (Array.isArray(response.data['items'])) {
          $.each(response.data['items'], function(index, item) {
            if (_this.itemIds.indexOf(item['id']) < 0) {
              _this.itemIds.push(item['id']);
              item['archivesspace_uri'] = uri;

              _this.addItemOrder(item, _this.archivesSpaceRecordSelect['uri']);
            }
            else {
              _this.archivesSpaceRecordSelect['alert'] = "One or more containers corresponding to the ArchivesSpace record is already included in the order. The ArchivesSpace URI entered will be added for reference.";
              addArchivesSpaceUriToItemOrder(item['id'], _this.archivesSpaceRecordSelect['uri']);
            }
          });
          // _this.archivesSpaceRecordSelect['uri'] = null;
          // _this.archivesSpaceRecordSelect['digitalObject'] = false;
          _this.commonUtils.executeCallback(callback, response.data);
        }
        else {
          _this.archivesSpaceRecordSelect['alert'] = 'The ArchivesSpace record at ' + uri + ' has no linked containers and cannot be ordered.';
        }
      }
      else {
        _this.archivesSpaceRecordSelect['alert'] = response.data['error']['detail'];
      }
      _this.initializeArchivesSpaceRecordSelect();
    });
  }

}
