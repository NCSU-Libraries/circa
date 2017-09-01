// extends DashboardCtrl

DashboardCtrl.prototype.getDigitalObjectRequests = function() {
  this.dashbaordLoading = true;
  var _this = this;
  var path = '/items/digital_object_requests';
  this.apiRequests.get(path).then(function(response) {
    _this.dashbaordLoading = false;
    if (response.status == 200) {
      _this.digitalObjectRequests = response.data;
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.flash = response.data['error']['detail'];
    }
  });
}
