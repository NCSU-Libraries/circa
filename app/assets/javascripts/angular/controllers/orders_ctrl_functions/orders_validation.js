OrdersCtrl.prototype.validateOrder = function() {
  var valid = true;
  var _this = this;

  this.validationErrors = {};
  this.hasValidationErrors = false;

  this.validateOrderType();
  this.validateOrderSubType();
  this.validateItems();
  this.validateAccessDate();
  this.validateReproductionSpec();
  this.validateOrderFee();
  this.validateUsersAndAssignees();

  function blank(value) {
    return (!value || (typeof value == 'string' && value.length == 0));
  }

  function removeEmptyArrayValues() {
    var validationErrors = _this.validationErrors;
    for (key in validationErrors) {
      var value = validationErrors[key];
      if (Array.isArray(value)) {
        if (value.length == 0) {
          delete _this.validationErrors[key];
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
            delete _this.validationErrors[key];
          }
        }
      }
    }
  }

  removeEmptyArrayValues();

  if (Object.keys(this.validationErrors).length > 0) {
    valid = false;
    this.hasValidationErrors = true;
  }

  return valid;
}


OrdersCtrl.prototype.validateOrderType = function() {
  if (!this.order['order_type_id']) {
    this.validationErrors['order_type_id'] = "Order type must be selected";
  }
}


OrdersCtrl.prototype.validateOrderSubType = function() {
  if (!this.order['order_sub_type_id']) {
    this.validationErrors['order_sub_type_id'] = "Order type must be selected";
  }
}


OrdersCtrl.prototype.validateItems = function() {
  if (this.order['order_type']['name'] == 'reproduction') {
    if (this.order['item_orders'].length == 0 &&
        this.order['digital_collections_orders'].length == 0) {
      this.validationErrors['items'] =
          "Order must include at least one item or digital image";
    }
  }
  else {
    if (this.order['item_orders'].length == 0) {
      this.validationErrors['items'] = "Order must include at least one item.";
    }
  }
}


OrdersCtrl.prototype.validateAccessDate = function() {
  if (!this.order['access_date_start']) {
    this.validationErrors['access_date'] = "A date must be provided";
  }
}


OrdersCtrl.prototype.validateUsersAndAssignees = function() {
  if (this.order['users'].length == 0 && this.order['assignees'].length == 0) {
    this.validationErrors['users'] =
        "Order must be associated with a user, assigned to a staff member, or both.";
    this.validationErrors['assignees'] =
        "Order must be associated with a user, assigned to a staff member, or both.";
  }
}


OrdersCtrl.prototype.validateReproductionSpec = function() {
  var _this = this;
  this.validationErrors['reproduction_spec_detail'] = [];
  this.validationErrors['reproduction_spec_pages'] = [];
  this.validationErrors['reproduction_spec_format'] = [];
  this.validationErrors['item_order_fee_other_description'] = [];

  if (this.order['order_type']['name'] == 'reproduction') {
    this.order['item_orders'].forEach(function(itemOrder, index) {

      if (!itemOrder['reproduction_spec'] ||
          !itemOrder['reproduction_spec']['detail'] ||
          itemOrder['reproduction_spec']['detail'].length == 0) {
        _this.validationErrors['reproduction_spec_detail'][index] =
            "Details of items for reproduction must be provided";
      }
      else {
        _this.validationErrors['reproduction_spec_detail'][index] = null;
      }

      if (!itemOrder['reproduction_spec']['pages'] ||
          itemOrder['reproduction_spec']['pages'].length == 0) {
        _this.validationErrors['reproduction_spec_pages'][index] =
            "Number of pages must be provided";
      }
      else {
        _this.validationErrors['reproduction_spec_pages'][index] = null;
      }

      if (!itemOrder['reproduction_spec']['reproduction_format_id'] ||
          itemOrder['reproduction_spec']['reproduction_format_id'].length == 0) {
        _this.validationErrors['reproduction_spec_format'][index] =
            "Format must be selected";
      }
      else {
        _this.validationErrors['reproduction_spec_format'][index] = null
      }

      if (itemOrder['order_fee']) {
        if (itemOrder['order_fee']['per_order_fee'] &&
            itemOrder['order_fee']['per_order_fee'].length > 0) {
          if (!itemOrder['order_fee']['per_order_fee_description'] ||
              itemOrder['order_fee']['per_order_fee_description'].length == 0) {
            _this.validationErrors['item_order_fee_other_description'][index] =
                "Description must be provided if other fee is specified";
          }
          else {
            _this.validationErrors['item_order_fee_other_description'][index] = null
          }
        }
      }

    });
  }
}


OrdersCtrl.prototype.validateOrderFee = function() {
  if (this.order['order_fee']) {
    if (this.order['order_fee']['per_order_fee'] &&
        this.order['order_fee']['per_order_fee'].length > 0) {
      if (!this.order['order_fee']['per_order_fee_description'] ||
          this.order['order_fee']['per_order_fee_description'].length == 0) {
        this.validationErrors['order_fee_description'] =
            "Description must be provided if fee is specified";
      }
    }
  }
}



OrdersCtrl.prototype.hasValidationErrors = function() {
  var errors = Object.keys(this.validationErrors).length;
  if (errors > 0) {
    return true;
  }
  else {
    return false;
  }
}
