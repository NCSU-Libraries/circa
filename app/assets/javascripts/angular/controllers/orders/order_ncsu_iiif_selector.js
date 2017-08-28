// Initialize object used to manage NCSU digital image selections
OrderCtrl.prototype.initializeDigitalImageSelect = function() {
  return {
    'imageId': '',
    'manifest': null,
    'requestedImages': [],
    'loading': false,
    'alert': null
  };
}


OrderCtrl.prototype.getIIIFManifest = function(scope) {
  var path = 'ncsu_iiif_manifest'

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


  this.apiRequests.get(path, { 'params': { 'image_id': scope.digitalImageSelect.getUri } } ).then(function(response) {
    scope.itemEventLoading = false;
    if (response.status == 200) {

      console.log(response.data);
      var manifest = response.data;

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
      });
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      scope.flash = response.data['error']['detail'];
    }
  });
}
