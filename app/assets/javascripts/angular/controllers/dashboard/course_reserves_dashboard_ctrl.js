// ReturnsInTransitCtrl - inherits from DashboardCtrl

/*

var CourseReservesDashboardCtrl = function($scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils) {
  DashboardCtrl.call(this, $scope, $route, $routeParams, $location, $window, $modal, apiRequests, sessionCache, commonUtils, formUtils);

  // set pendingItemTransfers
  this.getCourseReserves();
}

CourseReservesDashboardCtrl.$inject = ['$scope', '$route', '$routeParams', '$location', '$window', '$modal', 'apiRequests', 'sessionCache', 'commonUtils', 'formUtils'];
CourseReservesDashboardCtrl.prototype = Object.create(DashboardCtrl.prototype);
circaControllers.controller('CourseReservesDashboardCtrl', CourseReservesDashboardCtrl);

CourseReservesDashboardCtrl.prototype.getCourseReserves = function() {
  this.loading = true;
  var _this = this;
  var path = '/orders/course_reserves';
  this.apiRequests.get(path).then(function(response) {
    _this.loading = false;
    if (response.status == 200) {
      _this.orders = response.data['orders'];
    }
    else if (response.data['error'] && response.data['error']['detail']) {
      _this.flash = response.data['error']['detail'];
    }
  });
}

*/
