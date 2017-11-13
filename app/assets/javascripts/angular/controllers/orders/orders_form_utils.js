OrdersCtrl.prototype.applyOrderFormUtilityFunctions = function(scope) {

  var _this = this;

  scope.orderTypeIdMatch = function(typeId) {
    _this.orderTypeIdMatch(scope, typeId);
  }

  scope.setOrderType = function(orderTypes) {
    _this.setOrderType(scope, orderTypes);
  }

  scope.setOrderSubType = function(orderSubTypes) {
    _this.setOrderSubType(scope, orderSubTypes);
  }

  // scope.dateSingleOrRange = function() {
  //   return _this.dateSingleOrRange(scope);
  // }

}


OrdersCtrl.prototype.orderTypeIdMatch = function(scope, typeId) {
  if (scope.order['order_type_id'] == typeId) {
    return true;
  }
  else {
    return false;
  }
}


OrdersCtrl.prototype.setOrderType = function(scope, orderTypes) {
  var value = this.getControlledValue(orderTypes, scope.order['order_type_id']);
  scope.order['order_type'] = value;

  if (value['default_order_sub_type_id']) {
    scope.order['order_sub_type'] = value['default_order_sub_type'] || null;
    scope.order['order_sub_type_id'] = value['default_order_sub_type_id'] || null;
    if (value['default_order_sub_type']) {
      var defaultLocationId =
          value['default_order_sub_type']['default_location_id'] || null;
      scope.order['location_id'] = defaultLocationId;
    }
  }

  this.setDateSingleOrRange(scope);
  scope.userLabel = this.userLabel(scope);
}


OrdersCtrl.prototype.setOrderSubType = function(scope, orderSubTypes) {
  var orderSubType =
      this.getControlledValue(orderSubTypes, scope.order['order_sub_type_id']);

  scope.order['order_sub_type'] = orderSubType;
  var defaultLocationId = orderSubType.default_location_id;
  scope.order['location_id'] = defaultLocationId;

  this.setDateSingleOrRange(scope);

  if (orderSubType['name'] == 'reproduction_fee') {
    this.enableFees(scope);
  }
}


OrdersCtrl.prototype.dateSingleOrRange = function(scope) {
  var val = 'range';

  if (scope.order['order_type'] && scope.order['order_sub_type']) {
    if (scope.order['order_type']['name'] == 'research' &&
        scope.order['order_sub_type']['name'] != 'course_reserve') {
      val = 'single';
    }
    else if (scope.order['order_type']['name'] == 'reproduction') {
      val = 'single';
    }
  }

  return val;
}


OrdersCtrl.prototype.setDateSingleOrRange = function(scope) {
  scope.order['dateSingleOrRange'] = this.dateSingleOrRange(scope);
}
