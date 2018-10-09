// OrdersCloneCtrl - For clone/new view, inherits from OrdersCtrl

var OrdersCloneCtrl = function($route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils) {

  OrdersCtrl.call(this, $route, $routeParams, $location, $window, apiRequests, sessionCache, commonUtils, formUtils);

  var _this = this;

  this.mode = 'new';

  var callback = function() {
    _this.setDefaultPrimaryUserId();
    _this.dateSingleOrRange = _this.dateSingleOrRange();
  }

  this.cloneOrder($routeParams.orderId, callback);
  this.initializeOrderFormComponents();

  // For clone/edit views, load record after cache is loaded to ensure that
  //   controlled/enumerable values are ready
  // UPDATE : MAYBE NOT?
  var processCache = function(cache) {
    _this.processCache(cache);
    // _this.cloneOrder($routeParams.orderId, callback);
  }

  if ($routeParams.orderId) {
    var cache = sessionCache.init(this.processCache);
    this.clonedFromOrderId = $routeParams.orderId;
  }
  else {
    this.goto('orders/new');
  }
}

OrdersCloneCtrl.prototype = Object.create(OrdersCtrl.prototype);

OrdersCloneCtrl.$inject = ['$route', '$routeParams', '$location',
    '$window', 'apiRequests', 'sessionCache', 'commonUtils',
    'formUtils'];

circaControllers.controller('OrdersCloneCtrl', OrdersCloneCtrl);


// OrdersCloneCtrl.prototype.cloneOrder = function(id, callback) {
//   var path = '/orders/' + id;
//   var _this = this;
//   var preserveKeys = Object.keys(this.initializeOrder());

//   this.loading = true;

//   this.apiRequests.get(path).then(function(response) {
//     if (response.status == 200) {
//       var order = response.data['order'];

//       var deleteKeys = ['id', 'access_date_start', 'access_date_end',
//           'confirmed', 'open', 'created_at', 'updated_at', 'current_state',
//           'permitted_events', 'available_events', 'states_events',
//           'created_by_user', 'assignees'];

//       order['users'] = order['users'].filter(function(user) {
//         return user['id'] == order['primary_user_id'];
//       });

//       order['cloned_order_id'] = id;

//       for (var i = 0; i < deleteKeys.length; i++) {
//         delete order[deleteKeys[i]];
//       }

//       _this.loading = false;
//       _this.refreshOrder(order, callback);
//       console.log(this.order);
//     }
//     else if (response.data['error'] && response.data['error']['detail']) {
//       _this.errorCode = response.status;
//       _this.flash = response.data['error']['detail'];
//     }
//   });
// }
