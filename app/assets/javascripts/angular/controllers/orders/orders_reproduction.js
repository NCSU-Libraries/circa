OrdersCtrl.prototype.applyReproductionFunctions = function(scope) {

  var _this = this;

  scope.setReproductionFormat = function(record) {
    _this.setReproductionFormat(scope, record);
  }

  scope.showCustomUnitFee = function(record) {
    _this.showCustomUnitFee(scope, record);
  }

  scope.hideCustomUnitFee = function(record) {
    _this.hideCustomUnitFee(scope, record);
  }

}


OrdersCtrl.prototype.setReproductionFormat = function(scope, record) {
  var formatId = record['reproduction_spec']['reproduction_format_id'];

  var format = this.controlledValues['reproduction_format'].find(function(element) {
    return element.id == formatId;
  });

  console.log(format);

  if (format) {
    record['reproduction_format'] = format;
    record['order_fee'] = {};
    this.setUnitFeeOptions(record, format);
  }
}


OrdersCtrl.prototype.setUnitFeeOptions = function(record, reproductionFormat) {
  var options = [];
  if (reproductionFormat.default_unit_fee) {
    options.push({ name: 'default', value: reproductionFormat.default_unit_fee });
  }
  if (reproductionFormat.default_unit_fee_internal && reproductionFormat.default_unit_fee_external) {
    options.push({ name: 'default_internal', value: reproductionFormat.default_unit_fee_internal });
    options.push({ name: 'default_external', value: reproductionFormat.default_unit_fee_external });
  }
  if (options.length > 0) {
    record['order_fee']['per_unit_fee'] = options[0]['value'];
  }
  record['order_fee']['unit_fee_options'] = options;
}


OrdersCtrl.prototype.showCustomUnitFee = function(scope, record) {
  record['order_fee']['showCustom'] = true;
}


OrdersCtrl.prototype.hideCustomUnitFee = function(scope, record) {
  delete record['order_fee']['showCustom'];
}
