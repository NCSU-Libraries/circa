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

  console.log(record['reproduction_spec']['reproduction_format_id']);
  console.log(this.controlledValues['reproduction_format']);

  var formatId = record['reproduction_spec']['reproduction_format_id'];

  var format = this.controlledValues['reproduction_format'].find(function(element) {
    return element.id == formatId;
  });

  console.log(format);

  if (format) {
    record['reproduction_format'] = format;
    record['order_fee'] = {};
    record['order_fee']['per_unit_fee'] = format['default_unit_fee_internal'] || null;
  }

}


OrdersCtrl.prototype.showCustomUnitFee = function(scope, record) {
  record['order_fee']['showCustom'] = true;
}


OrdersCtrl.prototype.hideCustomUnitFee = function(scope, record) {
  delete record['order_fee']['showCustom'];
}
