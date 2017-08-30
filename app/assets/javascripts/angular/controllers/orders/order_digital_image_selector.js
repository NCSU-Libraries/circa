OrderCtrl.prototype.applyNCSUDigitalImageFunctions = function(scope) {

  var _this = this;

  scope.getIIIFManifest = function() {
    _this.getIIIFManifest(scope);
  }

  scope.requestedImagesToggle = function(id) {
    _this.requestedImagesToggle(scope, id);
  }

  scope.imageRequested = function(id) {
    return scope.digitalImageSelect['requestedImages'].hasOwnProperty(id);
  }

  scope.totalImages = function() {
    return Object.keys(scope.digitalImageSelect['images']).length;
  }

  scope.totalRequestedImages = function() {
    return Object.keys(scope.digitalImageSelect['requestedImages']).length;
  }

  scope.applyDigitalImageSelection = function() {
    _this.applyDigitalImageSelection(scope);
  }

}


// Initialize object used to manage NCSU digital image selections
OrderCtrl.prototype.initializeDigitalImageSelect = function(scope) {
  scope.digitalImageSelect = {
    identifier: '',
    label: '',
    manifest: null,
    requestedImages: {},
    images: {},
    loading: false,
    alert: null,
    uri: '',
    getUri: ''
  };
}


OrderCtrl.prototype.applyDigitalImageSelection = function(scope) {
  scope.order['digital_image_orders'] = scope.order['digital_image_orders'] || [];
  var digitalImageOrder = {
    image_id: scope.digitalImageSelect['identifier'],
    requested_images: scope.digitalImageSelect['requestedImages'],
    uri: scope.digitalImageSelect['uri'],
    label: scope.digitalImageSelect['label']
  }
  scope.order['digital_image_orders'].push(digitalImageOrder);
  this.initializeDigitalImageSelect(scope);
}


OrderCtrl.prototype.requestedImagesToggle = function(scope, id) {
  if (scope.digitalImageSelect['requestedImages'].hasOwnProperty(id)) {
    console.log('remove');
    delete scope.digitalImageSelect['requestedImages'][id];
  }
  else {
    console.log('add');
    scope.digitalImageSelect['requestedImages'][id] = scope.digitalImageSelect['images'][id];
  }
}


OrderCtrl.prototype.getIIIFManifest = function(scope) {
  var path = 'ncsu_iiif_manifest'
  var _this = this;

  this.apiRequests.get(path, { 'params': { 'image_id': scope.digitalImageSelect.getUri } } ).then(function(response) {
    scope.itemEventLoading = false;
    if (response.status == 200) {
      var manifest = response.data;
      _this.processIIIFManifest(scope, manifest);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
}


OrderCtrl.prototype.processIIIFManifest = function(scope, manifest) {

  function thumbnailUrl(image) {
    var serviceId = image['resource']['service']['@id'];
    var region = 'full';
    var maxWidth = 90;
    var maxHeight = Math.floor(maxWidth * 1.618);
    var dimensions;
    dimensions = '!' + maxWidth + ',' + maxHeight;
    var rotation = this.thumbnailRotation;
    var urlExtension = '/' + region + '/' +  dimensions + '/0/default.jpg';
    return serviceId + urlExtension;
  }

  function firstSequence(manifest) {
    if (manifest['sequences'] && manifest['sequences'][0]) {
      return manifest['sequences'][0];
    }
  }

  function firstCanvas(sequence) {
    if (sequence['canvases'] && sequence['canvases'][0]) {
      return sequence['canvases'][0];
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
    return idSplit[ idSplit.length -1 ]
  }

  function identifierFromCanvas(canvas) {
    var id = canvas['@id'];
    var idSplit = id.split('/');
    return idSplit[ idSplit.length -1 ]
  }

  scope.digitalImageSelect['uri'] = scope.digitalImageSelect['getUri'];
  scope.digitalImageSelect['getUri'] = '';
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
    scope.digitalImageSelect['requestedImages'][imageId] = thumbnail;
  });
}
