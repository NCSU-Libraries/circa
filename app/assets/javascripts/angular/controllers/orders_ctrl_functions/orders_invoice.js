OrdersCtrl.prototype.updateInvoice = function() {
  this.invoiceUpdated = false;
  this.invoiceUpdateError = null;
  var _this = this;
  var path = 'orders/' + this.order.id + '/invoice'
  data = { invoice: this.order.invoice };

  function unsetInvoiceUpdated() {
    _this.invoiceUpdated = false;
    console.log("invoiceUpdated: " + _this.invoiceUpdated);
  }

  this.apiRequests.put(path, data).then(function(response) {
    _this.itemEventLoading = false;
    if (response.status == 200) {
      _this.invoiceUpdateError = null;
      _this.invoiceUpdated = true;
      console.log("invoiceUpdated: " + _this.invoiceUpdated);
      setTimeout(unsetInvoiceUpdated, 5000);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.invoiceUpdateError = response.data['error']['detail'];
    }
  });
}


OrdersCtrl.prototype.defaultRecipientText = function() {
  var user = this.order.users[0];

  if (user) {
    var addressParts = []

    function addPartIfExists(key) {
      if (user[key] && user[key].length > 0) {
        addressParts.push(user[key]);
      }
    }

   ['display_name', 'address1', 'address2'].forEach(addPartIfExists);
   city = user.city ? user.city : '';
   cityStateSep = (user.city && user.state) ? ', ' : '';
   state = user.state ? user.state : '';
   zipSep = user.zip ? '  ' : ''
   zip = user.zip ? user.zip : ''
   cityLine = (city + cityStateSep + state + zipSep + zip).trim();
   if (cityLine.length > 0) {
    addressParts.push(cityLine);
   }
   ['phone', 'email'].forEach(addPartIfExists);

    return addressParts.join("\n").trim();
  }
}


OrdersCtrl.prototype.customizeRecipient = function() {
  if (!this.order.invoice.custom_to) {
    this.order.invoice.custom_to = this.defaultRecipientText();
  }
}


OrdersCtrl.prototype.revertRecipientToDefault = function() {
  this.order.invoice.custom_to = null;
}




