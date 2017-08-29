OrderCtrl.prototype.applyNCSUDigitalImageFunctions = function(scope) {
  var _this = this;

  scope.getIIIFManifest = function() {
    _this.getIIIFManifest(scope);
  }

  scope.requestedImagesToggle = function(identifier) {
    _this.requestedImagesToggle(scope, identifier);
  }

  scope.imageRequested = function(identifier) {
    return scope.digitalImageSelect.requestedImages.indexOf(identifier) >= 0;
  }
}


// Initialize object used to manage NCSU digital image selections
OrderCtrl.prototype.initializeDigitalImageSelect = function(scope) {
  scope.digitalImageSelect = {
    'identifier': '',
    'manifest': null,
    'requestedImages': [],
    'loading': false,
    'alert': null
  };
}


OrderCtrl.prototype.applyDigitalImageSelection = function(scope) {
  scope.order['digital_image_orders'] = scope.order['digital_image_orders'] || [];

  var digitalImageOrder = {
    image_id: scope.digitalImageSelect['identifier'],
    requested_images: scope.digitalImageSelect['requestedImages']
  }
  scope.order['digital_image_orders'].push(digitalImageOrder);
}


OrderCtrl.prototype.requestedImagesToggle = function(scope, identifier) {
  this.commonUtils['toggleArrayElement'](scope.digitalImageSelect['requestedImages'], identifier);
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
  scope.digitalImageSelect['images'] = [];

  var sequence = firstSequence(manifest);
  sequence.canvases.forEach(function(canvas) {
    var image = firstImage(canvas);
    image['thumbnail'] = thumbnailUrl(image);
    image['identifier'] = identifierFromCanvas(canvas);
    scope.digitalImageSelect['images'].push(image);
    scope.digitalImageSelect['requestedImages'].push(image['identifier']);
  });
}
