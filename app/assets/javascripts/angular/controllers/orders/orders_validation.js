OrdersCtrl.prototype.applyValidationFunctions = function(scope) {

  var _this = this;

  scope.validateOrder = function() {
    _this.validateOrder(scope);
  }

  scope.hasValidationErrors = function() {
    _this.hasValidationErrors(scope);
  }

}


OrdersCtrl.prototype.validateOrder = function(scope) {
  var valid = true;
  scope.validationErrors = {};
  scope.hasValidationErrors = false;

  // if (!scope.order['order_type_id']) {
  //   scope.validationErrors['order_type_id'] = "Order type must be selected";
  // }
  this.validateOrderType(scope);

  // if (!scope.order['order_sub_type_id']) {
  //   scope.validationErrors['order_sub_type_id'] = "Order type must be selected";
  // }
  this.validateOrderSubType(scope);

  // if (scope.order['item_orders'].length == 0 && scope.order['digital_image_orders'].length == 0) {
  //   scope.validationErrors['item_orders'] = "Order must include at least one item.";
  // }
  this.validateItems(scope);

  // if (!scope.order['access_date_start']) {
  //   scope.validationErrors['access_date'] = "A date must be provided.";
  // }
  this.validateAccessDate(scope);

  // if (scope.order['order_type'] && (scope.order['order_type']['name'] != 'research') && !scope.order['access_date_end']) {
  //   scope.validationErrors['access_date'] = "End is date required.";
  // }

  if (scope.order['users'].length == 0 && scope.order['assignees'].length == 0) {
    scope.validationErrors['users'] = "Order must be associated with a user, assigned to a staff member, or both.";
    scope.validationErrors['assignees'] = "Order must be associated with a user, assigned to a staff member, or both.";
  }

  if (Object.keys(scope.validationErrors).length > 0) {
    valid = false;
    scope.hasValidationErrors = true;
  }

  console.log(scope.validationErrors);

  return valid;
}


OrdersCtrl.prototype.validateOrderType = function(scope) {
  if (!scope.order['order_type_id']) {
    scope.validationErrors['order_type_id'] = "Order type must be selected";
  }
}


OrdersCtrl.prototype.validateOrderSubType = function(scope) {
  if (!scope.order['order_sub_type_id']) {
    scope.validationErrors['order_sub_type_id'] = "Order type must be selected";
  }
}


OrdersCtrl.prototype.validateItems = function(scope) {
  if (scope.order['order_type']['name'] == 'reproduction') {
    if (scope.order['item_orders'].length == 0 && scope.order['digital_image_orders'].length == 0) {
      scope.validationErrors['items'] = "Order must include at least one item or digital image.";
    }
  }
  else {
    if (scope.order['item_orders'].length == 0) {
      scope.validationErrors['items'] = "Order must include at least one item.";
    }
  }
}


OrdersCtrl.prototype.validateAccessDate = function(scope) {
  if (!scope.order['access_date_start']) {
    scope.validationErrors['access_date'] = "A date must be provided.";
  }
}


OrdersCtrl.prototype.hasValidationErrors = function(scope) {
  var errors = Object.keys(scope.validationErrors).length;
  console.log(errors + " errors");
  if (errors > 0) {
    return true;
  }
  else {
    return false;
  }
}
