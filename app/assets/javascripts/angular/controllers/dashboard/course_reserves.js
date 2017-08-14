// extends DashboardCtrl

DashboardCtrl.prototype.getCourseReserves = function() {
  if (!this.course_reserves) {
    this.loading = true;
    var _this = this;
    var path = '/orders/course_reserves';
    this.apiRequests.get(path).then(function(response) {
      _this.loading = false;
      if (response.status == 200) {
        _this.course_reserves = response.data['orders'];
      }
      else if (response.data['error'] && response.data['error']['detail']) {
        _this.flash = response.data['error']['detail'];
      }
    });
  }
}
