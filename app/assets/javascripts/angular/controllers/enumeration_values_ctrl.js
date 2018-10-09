// Enumeration values

var EnumerationValuesCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  var _this = this;

  SettingsCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);
}

EnumerationValuesCtrl.prototype = Object.create(SettingsCtrl.prototype);
EnumerationValuesCtrl.$inject = ['$route', '$routeParams', '$location', '$window', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('EnumerationValuesCtrl', EnumerationValuesCtrl);


EnumerationValuesCtrl.prototype.enumerationValuesListTitle = function() {
  var titles = {
    order_type: 'Order types',
    researcher_type: 'Researcher types',
    location_source: 'Location sources',
    user_role: 'User roles'
  }
  if (titles[this.enumerationName]) {
    return titles[this.enumerationName];
  }
  else {
    return 'Enumeration values';
  }
}


EnumerationValuesCtrl.prototype.getEnumerationValuesList = function(enumerationName, callback) {
  this.loading = true;
  var _this = this;
  var path = '/enumeration_values/?enumeration_name=' + enumerationName;
  this.apiRequests.get(path).then(function(response) {
    _this.loading = false;
    if (response.status == 200) {
      // NOTE: this.enumerationValues is set on every page when the cache is set - don't use that one
      _this.enumerationValuesList = response.data['enumeration_values'][enumerationName];
      _this.commonUtils.executeCallback(callback);
    }
    else {
      _this.error = response.data['error'];
    }
  });
}


EnumerationValuesCtrl.prototype.getEnumerationValue = function(id, callback) {
  this.loading = true;
  var _this = this;
  var path = '/enumeration_values/' + id;

  this.apiRequests.get(path).then(function(response) {
    _this.loading = false;
    if (response.status == 200) {
      _this.enumerationValue = response.data['enumeration_value'];
      _this.enumerationName = response.data['enumeration_value']['enumeration_name'];
      _this.commonUtils.executeCallback(callback);
    }
    else {
      _this.error = response.data['error'];
    }
  });
}


EnumerationValuesCtrl.prototype.updateEnumerationValue = function(callback) {
  this.loading = true;
  var _this = this;
  var path = '/enumeration_values/' + this.enumerationValue.id;

  this.apiRequests.put(path, { enumeration_value: this.enumerationValue }).then(function(response) {
    _this.loading = false;
    if (response.status == 200) {
      _this.goto('/settings/enumeration_values/list/' + _this.enumerationValue['enumeration_name'])
    }
    else {
      _this.error = response.data['error'];
    }
  });
}


EnumerationValuesCtrl.prototype.createEnumerationValue = function(callback) {
  this.loading = true;
  var _this = this;
  var path = '/enumeration_values/';
  var postData = {
    enumeration_name: this.enumerationName,
    enumeration_value: this.enumerationValue
  }
  this.apiRequests.post(path, postData).then(function(response) {
    _this.loading = false;
    if (response.status == 200) {
      _this.goto('/settings/enumeration_values/list/' + _this.enumerationName)
    }
    else {
      _this.error = response.data['error'];
    }
  });
}


EnumerationValuesCtrl.prototype.mergeEnumerationValues = function(callback) {
  this.loading = true;
  var _this = this;
  var path = '/enumeration_values/merge';
  var putData = {
    merge_from_id: this.enumerationValue.id,
    merge_into_id: this.mergeIntoId,
    enumeration_name: this.enumerationName
  }
  this.apiRequests.put(path, putData).then(function(response) {
    _this.loading = false;
    if (response.status == 200) {
      _this.goto('/settings/enumeration_values/list/' + _this.enumerationName)
    }
    else {
      _this.error = response.data['error'];
    }
  });
}


EnumerationValuesCtrl.prototype.updateSortOrder = function(enumerationName, index, delta, callback) {
  var _this = this;

  var sorted_values = this.commonUtils.shiftPositionOfItemInArray(this.enumerationValuesList, index, delta)

  var postData = { enumeration_name: enumerationName, enumeration_values: sorted_values };
  _this.apiRequests.post('/enumeration_values/update_order', postData).then(function(response) {
    _this.loading = false;
    if (response.status == 200) {
     _this.enumerationValuesList = response.data['enumeration_values'][enumerationName];
      _this.commonUtils.executeCallback(callback);
    }
    else {
      _this.error = response.data['error'];
    }
  });
}
