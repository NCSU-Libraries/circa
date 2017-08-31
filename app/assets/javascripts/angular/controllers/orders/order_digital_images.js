function thumbnailUrl(image) {
  var serviceId = image['resource']['service']['@id'];
  var region = 'full';
  var maxWidth = 90;
  var maxHeight = Math.floor(maxWidth * 1.618);
  var dimensions;
  dimensions = '!' + maxWidth + ',' + maxHeight;
  var urlExtension = '/' + region + '/' +  dimensions + '/0/default.jpg';
  return serviceId + urlExtension;
}


function firstSequence(manifest) {
  if (manifest['sequences'] && manifest['sequences'][0]) {
    return manifest['sequences'][0];
  }
}


function firstImage(canvas) {
  if (canvas['images'] && canvas['images'][0]) {
    return canvas['images'][0];
  }
}


function identifierFromManifest(manifest) {
  var id = manifest.related['@id'];
  var idSplit = id.split('/');
  return idSplit[ idSplit.length -1 ];
}


function identifierFromCanvas(canvas) {
  var id = canvas['@id'];
  var idSplit = id.split('/');
  return idSplit[ idSplit.length -1 ];
}


OrderCtrl.prototype.applyDigitalImageFunctions = function(scope) {

  var _this = this;

  scope.getNewDigitalImage = function() {
    _this.getNewDigitalImage(scope);
  }

  scope.requestedImagesToggle = function(id) {
    _this.requestedImagesToggle(scope, id);
  }

  scope.reloadDigitalImageSelect = function(digitalImageOrder) {
    _this.reloadDigitalImageSelect(scope, digitalImageOrder);
  }

  scope.removeDigitalImageOrder = function(digitalImageOrder) {
    _this.removeDigitalImageOrder(scope, digitalImageOrder);
  }

  scope.initializeDigitalImageSelect = function() {
    _this.initializeDigitalImageSelect(scope);
  }

  scope.imageRequested = function(id) {
    return scope.digitalImageSelect['requestedImages'].indexOf(id) >= 0;
  }

  scope.totalImages = function() {
    return Object.keys(scope.digitalImageSelect['images']).length;
  }

  scope.totalRequestedImages = function() {
    return scope.digitalImageSelect['requestedImages'].length;
  }

  scope.applyDigitalImageSelection = function() {
    _this.applyDigitalImageSelection(scope);
  }

  scope.orderIncludesDigitalImageOrder = function(identifier) {
    return _this.orderIncludesDigitalImageOrder(scope, identifier);
  }

  scope.restoreDigitalImageOrder = function(digitalImageOrder) {
    _this.restoreDigitalImageOrder(scope, digitalImageOrder);
  }

}


OrderCtrl.prototype.editDigitalImageSelection = function(scope, digitalImageOrder) {
  this.initializeDigitalImageSelect();
  var removedDigitalImageOrder = this.getDigitalImageOrder(scope, digitalImageOrder['image_id']);
}


OrderCtrl.prototype.getDigitalImageOrderIndex = function(scope, identifier) {
  var digitalImageOrderIndex = scope.order['digital_image_orders'].findIndex(function(element) {
    return element['image_id'] == identifier;
  });
  return digitalImageOrderIndex;
}


OrderCtrl.prototype.orderIncludesDigitalImageOrder = function(scope, identifier) {
  var digitalImageOrderIndex = this.getDigitalImageOrderIndex(scope,identifier);
  return digitalImageOrderIndex >= 0;
}


OrderCtrl.prototype.getDigitalImageOrder = function(scope, identifier) {
  var index = this.getDigitalImageOrderIndex(scope, identifier);

  if (index && index >= 0) {
    return scope.order['digital_image_orders'][index];
  }
}


OrderCtrl.prototype.removeDigitalImageOrder = function(scope, digitalImageOrder) {
  var index = this.getDigitalImageOrderIndex(scope, digitalImageOrder.image_id);
  if (index >= 0) {
    var removedDigitalImageOrder = scope.order['digital_image_orders'].splice(index, 1)[0];
  }
  this.commonUtils.addToArray(scope.removedDigitalImageOrders, digitalImageOrder);
}


OrderCtrl.prototype.restoreDigitalImageOrder = function(scope, digitalImageOrder) {
  this.commonUtils.removeFromArray(scope.removedDigitalImageOrders, digitalImageOrder);
  this.commonUtils.addToArray(scope.order['digital_image_orders'], digitalImageOrder);
}


// Initialize object used to manage NCSU digital image selections
OrderCtrl.prototype.initializeDigitalImageSelect = function(scope) {
  scope.digitalImageSelect = {
    identifier: '',
    label: '',
    manifest: null,
    requestedImages: [],
    images: {},
    loading: false,
    alert: null,
    uri: '',
    getId: '',
    getIdValue: ''
  };
}


// This binds the properties of digitalImageOrder to their corresponding properties in scope.digitalImageSelect
OrderCtrl.prototype.reloadDigitalImageSelect = function(scope, digitalImageOrder) {
  this.initializeDigitalImageSelect(scope);

  var _this = this;

  scope.digitalImageSelect['displayUri'] = digitalImageOrder.display_uri;
  scope.digitalImageSelect['manifestUri'] = digitalImageOrder.manifest_uri;
  scope.digitalImageSelect['identifier'] = digitalImageOrder.image_id;
  scope.digitalImageSelect['label'] = digitalImageOrder.label;
  scope.digitalImageSelect['requestedImages'] = digitalImageOrder.requested_images;
  scope.digitalImageSelect['getId'] = digitalImageOrder.image_id;

  var callback = function(scope, manifest) {
    scope.digitalImageSelect['manifest'] = manifest;
    scope.digitalImageSelect['images'] = {};

    var sequence = firstSequence(manifest);

    sequence.canvases.forEach(function(canvas) {
      var image = firstImage(canvas);
      var thumbnail = thumbnailUrl(image);
      var imageId = identifierFromCanvas(canvas);
      scope.digitalImageSelect['images'][imageId] = thumbnail;
    });
  }
  this.getManifest(scope, callback);
}


OrderCtrl.prototype.applyDigitalImageSelection = function(scope) {
  scope.order['digital_image_orders'] = scope.order['digital_image_orders'] || [];
  var digitalImageOrder = {
    image_id: scope.digitalImageSelect['identifier'],
    requested_images: scope.digitalImageSelect['requestedImages'],
    display_uri: scope.digitalImageSelect['displayUri'],
    manifest_uri: scope.digitalImageSelect['manifestUri'],
    label: scope.digitalImageSelect['label']
  }
  scope.order['digital_image_orders'].push(digitalImageOrder);
  this.initializeDigitalImageSelect(scope);
}


OrderCtrl.prototype.requestedImagesToggle = function(scope, id) {
  this.commonUtils.toggleArrayElement(scope.digitalImageSelect['requestedImages'], id)
}


OrderCtrl.prototype.getNewDigitalImage = function(scope) {
  var _this = this;
  var callback = function(scope, manifest) {
    _this.newDigitalImageFromManifest(scope, manifest);
  }
  scope.digitalImageSelect.getId = scope.digitalImageSelect.getIdValue;
  this.getManifest(scope, callback);
}


OrderCtrl.prototype.getManifest = function(scope, callback) {
  var path = 'ncsu_iiif_manifest'
  var _this = this;
  this.apiRequests.get(path, { 'params': { 'image_id': scope.digitalImageSelect.getId } } ).then(function(response) {
    scope.itemEventLoading = false;
    if (response.status == 200) {
      var manifest = response.data;

      console.log(manifest);

      if (typeof callback !== 'undefined') {
        callback(scope, manifest);
      }
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
}


OrderCtrl.prototype.newDigitalImageFromManifest = function(scope, manifest) {
  var _this = this;

  scope.digitalImageSelect['displayUri'] = manifest.related['@id'];
  scope.digitalImageSelect['manifestUri'] = manifest['@id'];
  scope.digitalImageSelect['getId'] = '';
  scope.digitalImageSelect['manifest'] = manifest;
  scope.digitalImageSelect['identifier'] = identifierFromManifest(manifest);
  scope.digitalImageSelect['label'] = manifest.label;
  scope.digitalImageSelect['images'] = {};

  var sequence = firstSequence(manifest);

  sequence.canvases.forEach(function(canvas) {
    var image = firstImage(canvas);
    var thumbnail = thumbnailUrl(image);
    var imageId = identifierFromCanvas(canvas);
    scope.digitalImageSelect['images'][imageId] = thumbnail;
    scope.digitalImageSelect['requestedImages'].push(imageId);
  });
}
