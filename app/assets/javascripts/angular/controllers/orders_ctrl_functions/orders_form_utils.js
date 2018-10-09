OrdersCtrl.prototype.orderTypeIdMatch = function(typeId) {
  if (this.order['order_type_id'] == typeId) {
    return true;
  }
  else {
    return false;
  }
}


OrdersCtrl.prototype.setOrderType = function(orderTypes) {
  var value = this.getControlledValue(orderTypes, this.order['order_type_id']);
  this.order['order_type'] = value;
  this.setUserLabel();

  if (value['default_order_sub_type_id']) {
    this.order['order_sub_type'] = value['default_order_sub_type'] || null;
    this.order['order_sub_type_id'] = value['default_order_sub_type_id'] || null;
    if (value['default_order_sub_type']) {
      var defaultLocationId =
          value['default_order_sub_type']['default_location_id'] || null;
      this.order['location_id'] = defaultLocationId;
    }
  }

  this.setDateSingleOrRange();
}


OrdersCtrl.prototype.setOrderSubType = function(orderSubTypes) {
  var orderSubType =
      this.getControlledValue(orderSubTypes, this.order['order_sub_type_id']);

  this.order['order_sub_type'] = orderSubType;
  var defaultLocationId = orderSubType.default_location_id;
  this.order['location_id'] = defaultLocationId;

  this.setDateSingleOrRange();

  if (orderSubType['name'] == 'reproduction_fee') {
    this.enableFees();
  }
}


OrdersCtrl.prototype.dateSingleOrRange = function() {
  var val = 'range';

  if (this.order['order_type'] && this.order['order_sub_type']) {
    if (this.order['order_type']['name'] == 'research' &&
        this.order['order_sub_type']['name'] != 'course_reserve') {
      val = 'single';
    }
    else if (this.order['order_type']['name'] == 'reproduction') {
      val = 'single';
    }
  }

  return val;
}


OrdersCtrl.prototype.setDateSingleOrRange = function() {
  this.order['dateSingleOrRange'] = this.dateSingleOrRange();
}
