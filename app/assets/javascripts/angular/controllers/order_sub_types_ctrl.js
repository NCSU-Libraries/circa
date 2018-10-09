// Enumeration values

var OrderSubTypesCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  var _this = this;

  SettingsCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);
}

OrderSubTypesCtrl.prototype = Object.create(SettingsCtrl.prototype);
OrderSubTypesCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('OrderSubTypesCtrl', OrderSubTypesCtrl);


OrderSubTypesCtrl.prototype.getOrderSubTypes = function(callback) {
  this.loading = true;
  var _this = this;
  var path = '/order_sub_types';
  this.apiRequests.get(path).then(function(response) {
    _this.loading = false;
    if (response.status == 200) {
      // NOTE: this.enumerationValues is set on every page when the cache is set - don't use that one
      _this.orderSubTypes = response.data['order_sub_types'];
      _this.commonUtils.executeCallback(callback);
    }
    else {
      _this.error = response.data['error'];
    }
  });
}

OrderSubTypesCtrl.prototype.getOrderSubType = function(id, callback) {
  this.loading = true;
  var _this = this;
  var path = '/order_sub_types/' + id;
  this.apiRequests.get(path).then(function(response) {
    _this.loading = false;
    if (response.status == 200) {
      _this.orderSubType = response.data['order_sub_type'];
      _this.orderType = response.data['order_sub_type']['order_type'];
      _this.commonUtils.executeCallback(callback);
    }
    else {
      _this.error = response.data['error'];
    }
  });
}


OrderSubTypesCtrl.prototype.updateOrderSubType = function(callback) {
  this.loading = true;
  var _this = this;
  var path = '/order_sub_types/' + this.orderSubType.id;
  this.apiRequests.put(path, { order_sub_type: this.orderSubType }).then(function(response) {
    _this.loading = false;
    if (response.status == 200) {
      _this.goto('/settings/order_sub_types');
    }
    else {
      _this.error = response.data['error'];
    }
  });
}
