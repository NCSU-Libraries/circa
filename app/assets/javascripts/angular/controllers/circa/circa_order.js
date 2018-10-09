CircaCtrl.prototype.showOrder = function(orderId) {
  this.goto('orders/' + orderId);
}


CircaCtrl.prototype.getOrder = function(id, callback) {
  var path = '/orders/' + id;
  var _this = this;
  this.loading = true;
  this.apiRequests.get(path).then(function(response) {
    if (response.status == 200) {

      _this.refreshOrder(response.data['order'], callback)
      _this.loading = false;
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.errorCode = response.status;
      _this.flash = response.data['error']['detail'];
    }
  });
}


CircaCtrl.prototype.refreshOrder = function(order, callback) {
  this.order = order;
  this.collectItemIds(order);
  this.collectUserEmails(order);
  this.collectAssigneeEmails(order);
  this.setStatesEvents();
  this.setCheckOutAvailable();
  this.addAllItemOrdersToBulkEventsList();
  this.setDateSingleOrRange();
  this.order['editInvoiceDate'] = !this.order['invoice_date'] ?
    true : false;
  this.order['editInvoicePaymentDate'] = !this.order['invoice_payment_date'] ?
    true : false;
  this.commonUtils.executeCallback(callback);
}


CircaCtrl.prototype.refreshCurrentOrder = function(callback) {
  if (this.order) {
    var orderId = this.order['id'];
    this.getOrder(orderId, callback);
  }
}


// Trigger event for order and reset this.order['states_events']
CircaCtrl.prototype.triggerOrderEvent = function(orderId, event, callback) {
  var path = '/orders/' + orderId + '/' + event;
  var _this = this;
  this.orderEventLoading = true;
  _this.apiRequests.put(path).then(function(response) {
    _this.orderEventLoading = false;
    if (response.status == 200) {
      _this.order = response.data['order'];
      _this.setStatesEvents();
      _this.commonUtils.executeCallback(callback, response.data);
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.flash = response.data['error']['detail'];
    }
  });
}


CircaCtrl.prototype.updateOrder = function(callback) {
  var _this = this;
  this.loading = true;
  var data = { 'order': this.order };

  this.apiRequests.put("orders/" + this.order['id'], data).then(function(response) {
    if (response.status == 200) {
      _this.order = response.data['order'];
      _this.goto('orders/' + _this.order['id']);
      _this.commonUtils.executeCallback(callback, response.data);
      _this.loading = false;
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.flash = response.data['error']['detail'];
    }
  });
}


CircaCtrl.prototype.updateAndRefreshOrder = function(event, callback) {
  var _this = this;
  this.loading = true;
  var data = { 'order': this.order };
  if (event) {
    data['event'] = event;
  }

  this.apiRequests.put("orders/" + this.order['id'], data).then(function(response) {
    if (response.status == 200) {
      _this.refreshOrder(response.data['order'], callback);
      _this.loading = false;
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.flash = response.data['error']['detail'];
    }
  });
}
