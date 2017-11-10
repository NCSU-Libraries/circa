OrdersCtrl.prototype.applyOrderValidationFunctions = function(scope) {

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

  this.validateOrderType(scope);
  this.validateOrderSubType(scope);
  this.validateItems(scope);
  this.validateAccessDate(scope);
  this.validateReproductionSpec(scope);
  this.validateOrderFee(scope);
  this.validateUsersAndAssignees(scope);

  function blank(value) {
    return (!value || (typeof value == 'string' && value.length == 0));
  }

  function removeEmptyArrayValues() {
    var validationErrors = scope.validationErrors;
    for (key in validationErrors) {
      var value = validationErrors[key];
      if (Array.isArray(value)) {
        if (value.length == 0) {
          delete scope.validationErrors[key];
        }
        else {
          var allBlank = true;
          for (var i = 0; i < value.length; i++) {
            if (!blank(value[i])) {
              allBlank = false;
              break;
            }
          }
          if (allBlank) {
            delete scope.validationErrors[key];
          }
        }
      }
    }
  }

  removeEmptyArrayValues();

  if (Object.keys(scope.validationErrors).length > 0) {
    valid = false;
    scope.hasValidationErrors = true;
  }

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
    if (scope.order['item_orders'].length == 0 &&
        scope.order['digital_image_orders'].length == 0) {
      scope.validationErrors['items'] =
          "Order must include at least one item or digital image";
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
    scope.validationErrors['access_date'] = "A date must be provided";
  }
}


OrdersCtrl.prototype.validateUsersAndAssignees = function(scope) {
  if (scope.order['users'].length == 0 && scope.order['assignees'].length == 0) {
    scope.validationErrors['users'] =
        "Order must be associated with a user, assigned to a staff member, or both.";
    scope.validationErrors['assignees'] =
        "Order must be associated with a user, assigned to a staff member, or both.";
  }
}


OrdersCtrl.prototype.validateReproductionSpec = function(scope) {
  scope.validationErrors['reproduction_spec_detail'] = [];
  scope.validationErrors['reproduction_spec_pages'] = [];
  scope.validationErrors['reproduction_spec_format'] = [];
  scope.validationErrors['item_order_fee_other_description'] = [];

  if (scope.order['order_type']['name'] == 'reproduction') {
    scope.order['item_orders'].forEach(function(itemOrder, index) {

      if (!itemOrder['reproduction_spec']['detail'] ||
          itemOrder['reproduction_spec']['detail'].length == 0) {
        scope.validationErrors['reproduction_spec_detail'][index] =
            "Details of items for reproduction must be provided";
      }
      else {
        scope.validationErrors['reproduction_spec_detail'][index] = null;
      }

      if (!itemOrder['reproduction_spec']['pages'] ||
          itemOrder['reproduction_spec']['pages'].length == 0) {
        scope.validationErrors['reproduction_spec_pages'][index] =
            "Number of pages must be provided";
      }
      else {
        scope.validationErrors['reproduction_spec_pages'][index] = null;
      }

      if (!itemOrder['reproduction_spec']['reproduction_format_id'] ||
          itemOrder['reproduction_spec']['reproduction_format_id'].length == 0) {
        scope.validationErrors['reproduction_spec_format'][index] =
            "Format must be selected";
      }
      else {
        scope.validationErrors['reproduction_spec_format'][index] = null
      }

      if (itemOrder['order_fee']) {
        if (itemOrder['order_fee']['per_order_fee'] &&
            itemOrder['order_fee']['per_order_fee'].length > 0) {
          if (!itemOrder['order_fee']['per_order_fee_description'] ||
              itemOrder['order_fee']['per_order_fee_description'].length == 0) {
            scope.validationErrors['item_order_fee_other_description'][index] =
                "Description must be provided if other fee is specified";
          }
          else {
            scope.validationErrors['item_order_fee_other_description'][index] = null
          }
        }
      }

    });
  }
}


OrdersCtrl.prototype.validateOrderFee = function(scope) {
  if (scope.order['order_fee']) {
    if (scope.order['order_fee']['per_order_fee'] &&
        scope.order['order_fee']['per_order_fee'].length > 0) {
      if (!scope.order['order_fee']['per_order_fee_description'] ||
          scope.order['order_fee']['per_order_fee_description'].length == 0) {
        scope.validationErrors['order_fee_description'] =
            "Description must be provided if fee is specified";
      }
    }
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
