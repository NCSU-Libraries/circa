circaApp.factory('reports', [ '$cacheFactory', 'apiRequests', 'commonUtils', function($cacheFactory, apiRequests, commonUtils) {

  var requestsPerResource = function() {
    path = '/states_events';
    apiRequests.get(path).then(function(response) {
      cache.put('orderStatesEvents', response.data['order_states_events']);
      cache.put('itemStatesEvents', response.data['item_states_events']);
      executeCallbackChain(cache);
    });
  }

  return {
    requestsPerResource: requestsPerResource
  };

}]);
