OrderCtrl.prototype.applyCatalogFunctions = function(scope) {

  scope.addItemFromCatalog = function(catalogRecordId, catalogItemId) {
    _this.addItemFromCatalog(catalogRecordId, catalogItemId, scope);
  }

  scope.getCatalogRecord = function() {
    _this.getCatalogRecord(scope);
  }

}


// Initialize object used to manage selections from catalog
OrderCtrl.prototype.initializeCatalogRecordSelect = function(scope) {
  scope.catalogRecordSelect = {
    'catalogRecordId': '', 'catalogRecordData': '', 'requestItemId': '', 'loading': false, 'alert': null
  };
}


// Object used to manage selections from catalog
// { 'catalogRecordId': '', 'catalogRecordData': null, 'requestItemId': '', 'loading': false, 'alert': null };

OrderCtrl.prototype.getCatalogRecord = function(scope, callback) {
  var _this = this;
  var catalogRecordId = scope.catalogRecordSelect['catalogRecordId'];
  scope.catalogRecordSelect['loading'] = true;
  scope.catalogRecordSelect['alert'] = null;

  _this.apiRequests.get('get_ncsu_catalog_record', { 'params': { 'catalog_record_id': catalogRecordId } } ).then(function(response) {
    scope.catalogRecordSelect['loading'] = false;
    if (response.status == 200) {
      scope.catalogRecordSelect['catalogRecordData'] = response.data['data'];
    }
  });
}


OrderCtrl.prototype.addItemFromCatalog = function(catalogRecordId, catalogItemId, scope, callback) {
  var _this = this;

  if (catalogRecordId.match(/\//)) {
    var urlParts = catalogRecordId.split('/');
    catalogRecordId = urlParts[urlParts.length - 1]
  }

  scope.catalogRecordSelect['loading'] = true;
  scope.catalogRecordSelect['alert'] = null;

  if (scope.order['catalog_items'].indexOf(catalogItemId) >= 0) {
    _this.initializeCatalogRecordSelect(scope);
    scope.catalogRecordSelect['alert'] = 'An item associated with item ' + catalogItemId + ' from catalog record with id ' + catalogRecordId + ' is already included in this order.';
  }
  else {
    scope.order['catalog_records'].push(catalogRecordId);
    scope.order['catalog_items'].push(catalogItemId);
    _this.apiRequests.post('items/create_from_catalog', { 'catalog_record_id': catalogRecordId, 'catalog_item_id': catalogItemId } ).then(function(response) {
      scope.catalogRecordSelect['loading'] = false;
      if (response.status == 200) {
        var item = response.data['item'];

        console.log(item);

        if (scope.itemIds.indexOf(item['id']) < 0) {
          scope.itemIds.push(item['id']);

          // REMOVED AFTER REMOVING items FROM order
          // scope.order['items'].push(item);

          _this.initializeCatalogRecordSelect(scope);
          // _this.addItemOrder(scope, item['id']);
          _this.addItemOrder(scope, item);
        }
        else {
          scope.catalogRecordSelect['alert'] = 'An item associated with the catalog record with id ' + catalogRecordId + ' is already included in this order.';
        }
      }
      else if (response.status == 500) {
        scope.catalogRecordSelect['alert'] = 'A system error has occurred (500)';
      }
    });
  }
}
