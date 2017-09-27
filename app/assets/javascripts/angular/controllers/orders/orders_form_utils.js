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

  scope.dateSingleOrRange = function() {
    return _this.dateSingleOrRange(scope);
  }

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
  scope.order['order_sub_type'] = null;
  scope.order['order_sub_type_id'] = null;
  scope.dateSingleOrRange = this.dateSingleOrRange(scope);
  scope.userLabel = this.userLabel(scope);
}


OrdersCtrl.prototype.setOrderSubType = function(scope, orderSubTypes) {
  var value =
      this.getControlledValue(orderSubTypes, scope.order['order_sub_type_id']);

  console.log(value);

  scope.order['order_sub_type'] = value;
  scope.dateSingleOrRange = this.dateSingleOrRange(scope);
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
