// Enumeration values

var EnumerationValuesCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {

  var _this = this;

  SettingsCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  $scope.updateSortOrder = function(enumerationName, index, delta, callback) {
    _this.updateSortOrder($scope, enumerationName, index, delta, callback);
  }

  $scope.updateEnumerationValue = function() {
    _this.updateEnumerationValue($scope);
  }

  $scope.createEnumerationValue = function() {
    _this.createEnumerationValue($scope);
  }

  $scope.mergeEnumerationValues = function() {
    _this.mergeEnumerationValues($scope);
  }

  $scope.enumerationValuesListTitle = function() {
    return _this.enumerationValuesListTitle($scope);
  }
}

EnumerationValuesCtrl.prototype = Object.create(SettingsCtrl.prototype);
EnumerationValuesCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
circaControllers.controller('EnumerationValuesCtrl', EnumerationValuesCtrl);


EnumerationValuesCtrl.prototype.enumerationValuesListTitle = function(scope) {
  var titles = {
    order_type: 'Order types',
    patron_type: 'Patron types',
    location_source: 'Location sources',
    user_role: 'User roles'
  }
  if (titles[scope.enumerationName]) {
    return titles[scope.enumerationName];
  }
  else {
    return 'Enumeration values';
  }
}


EnumerationValuesCtrl.prototype.getEnumerationValuesList = function(scope, enumerationName, callback) {
  scope.loading = true;
  var _this = this;
  var path = '/enumeration_values/?enumeration_name=' + enumerationName;
  this.apiRequests.get(path).then(function(response) {
    scope.loading = false;
    if (response.status == 200) {
      // NOTE: scope.enumerationValues is set on every page when the cache is set - don't use that one
      scope.enumerationValuesList = response.data['enumeration_values'][enumerationName];
      _this.commonUtils.executeCallback(callback, scope);
    }
    else {
      scope.error = response.data['error'];
    }
  });
}


EnumerationValuesCtrl.prototype.getEnumerationValue = function(scope, id, callback) {
  scope.loading = true;
  var _this = this;
  var path = '/enumeration_values/' + id;
  this.apiRequests.get(path).then(function(response) {
    scope.loading = false;
    if (response.status == 200) {
      scope.enumerationValue = response.data['enumeration_value'];
      scope.enumerationName = response.data['enumeration_value']['enumeration_name'];
      _this.commonUtils.executeCallback(callback, scope);
    }
    else {
      scope.error = response.data['error'];
    }
  });
}


EnumerationValuesCtrl.prototype.updateEnumerationValue = function(scope, callback) {
  scope.loading = true;
  var _this = this;
  var path = '/enumeration_values/' + scope.enumerationValue.id;
  this.apiRequests.put(path, { enumeration_value: scope.enumerationValue }).then(function(response) {
    scope.loading = false;
    if (response.status == 200) {
      _this.goto('/settings/enumeration_values/list/' + scope.enumerationValue['enumeration_name'])
    }
    else {
      scope.error = response.data['error'];
    }
  });
}


EnumerationValuesCtrl.prototype.createEnumerationValue = function(scope, callback) {
  scope.loading = true;
  var _this = this;
  var path = '/enumeration_values/';
  var postData = {
    enumeration_name: scope.enumerationName,
    enumeration_value: scope.enumerationValue
  }
  this.apiRequests.post(path, postData).then(function(response) {
    scope.loading = false;
    if (response.status == 200) {
      _this.goto('/settings/enumeration_values/list/' + scope.enumerationName)
    }
    else {
      scope.error = response.data['error'];
    }
  });
}


EnumerationValuesCtrl.prototype.mergeEnumerationValues = function(scope, callback) {
  scope.loading = true;
  var _this = this;
  var path = '/enumeration_values/merge';
  var putData = {
    merge_from_id: scope.enumerationValue.id,
    merge_into_id: scope.mergeIntoId,
    enumeration_name: scope.enumerationName
  }
  this.apiRequests.put(path, putData).then(function(response) {
    scope.loading = false;
    if (response.status == 200) {
      _this.goto('/settings/enumeration_values/list/' + scope.enumerationName)
    }
    else {
      scope.error = response.data['error'];
    }
  });
}


EnumerationValuesCtrl.prototype.updateSortOrder = function(scope, enumerationName, index, delta, callback) {
  console.log('this.updateSortOrder')
  var _this = this;

  var sorted_values = this.commonUtils.shiftPositionOfItemInArray(scope.enumerationValuesList, index, delta)

  var postData = { enumeration_name: enumerationName, enumeration_values: sorted_values };
  _this.apiRequests.post('/enumeration_values/update_order', postData).then(function(response) {
    scope.loading = false;
    if (response.status == 200) {
     scope.enumerationValuesList = response.data['enumeration_values'][enumerationName];
      _this.commonUtils.executeCallback(callback, scope);
    }
    else {
      scope.error = response.data['error'];
    }
  });
}
