OrdersCtrl.prototype.enableFees = function() {
  var _this = this;

  if (this.order && this.order['item_orders']) {
    this.order['item_orders'].forEach(function(itemOrder) {
      _this.setReproductionFormat(itemOrder);
    });
  }
}


OrdersCtrl.prototype.setReproductionFormat = function(record) {
  var formatId = record['reproduction_spec']['reproduction_format_id'];
  var format = this.controlledValues['reproduction_format'].find(function(element) {
    return element.id == formatId;
  });
  if (format) {
    record['reproduction_spec']['reproduction_format'] = format;
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
  record['order_fee']['unit_fee_options'] = options;
}


OrdersCtrl.prototype.setUnitFee = function(record, fee) {
  record['order_fee']['per_unit_fee'] = Number(fee).toFixed(2);
}


OrdersCtrl.prototype.showCustomUnitFee = function(record) {
  record['order_fee']['showCustom'] = true;
  record['order_fee']['custom'] = record['order_fee']['custom'] || record['order_fee']['per_unit_fee'];
  record['order_fee']['per_unit_fee'] = record['order_fee']['custom'];
}


OrdersCtrl.prototype.hideCustomUnitFee = function(record) {
  delete record['order_fee']['showCustom'];
}


OrdersCtrl.prototype.editInvoiceDate = function() {
  this.order['editInvoiceDate'] = true;
}


OrdersCtrl.prototype.editInvoicePaymentDate = function() {
  this.order['editInvoicePaymentDate'] = true;
}
