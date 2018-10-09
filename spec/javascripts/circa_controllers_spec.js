describe('CircaCtrl', function () {

  // Initialize vars
  var $scope;
  var $controller;
  var $location;
  var apiRequestsStub;
  var circaCtrl

  // module() is equiv to angular.mock.module();
  beforeEach(module('circaApp'));


  // See https://docs.angularjs.org/api/ngMock/function/angular.mock.inject
  beforeEach(inject(function(_$controller_, _$location_, _$modal_, apiRequests) {
    $controller = _$controller_;
    $location = _$location_;
    $modal = _$modal_;
    $scope = {};

    var fakePromise = { then: function() {} };

    apiRequestsStub = sinon.stub({
      get: function() {},
      post: function() {},
      put: function() {},
      delete: function() {},
      getPage: function() {},
      getCurrentUser: function() {},
      getEnumerationValues: function() {}
    });

    apiRequestsStub.get.returns(fakePromise);
    apiRequestsStub.post.returns(fakePromise);
    apiRequestsStub.put.returns(fakePromise);
    apiRequestsStub.delete.returns(fakePromise);
    apiRequestsStub.getPage.returns(fakePromise);
    apiRequestsStub.getCurrentUser.returns(fakePromise);
    apiRequestsStub.getEnumerationValues.returns(fakePromise);





    commonUtilsStub = sinon.stub({
      executeCallback: function() {},
      match: function() {},
      objectMerge: function() {},
      paginationParams: function() {},
      calculatePercent: function() {},
      addToArray: function() {},
      toggleArrayElement: function() {},
      inArray: function() {},
      urlHelpers: {},
      openModal: function() {},
      railsEnv: function() {}
    });

    commonUtilsStub.urlHelpers = sinon.stub({
      templateUrl: function() {},
      imageUrl: function() {},
      rootPath: function() {}
    });

    commonUtilsStub.urlHelpers.templateUrl.returns(
      function(template) {
        return '/path/to/template/' + template;
      }
    );


    circaCtrl = $controller('CircaCtrl', {
      '$scope': $scope,
      'apiRequests': apiRequestsStub,
      'commonUtils': commonUtilsStub
    });


    // *** Save for later ***
    // $httpBackend.whenGET('/orders/1')
    //   .respond({
    //     'order': {
    //       'id': 1,
    //       'users': [
    //         { 'id': 23, 'display_name': 'Don Ho' }
    //       ]
    //     }
    //   });

  }));


  describe('templateUrl', function() {
    it ('uses commonUtils.urlHelpers.templateUrl', function() {
      circaCtrl.templateUrl('template');
      expect(commonUtilsStub.urlHelpers.templateUrl.calledOnce).toBeTruthy();
    });
  });


  describe('getOrder', function() {

    it('uses apiRequests service to get order', function() {
      circaCtrl.getOrder(1);
      expect(apiRequestsStub.get.calledOnce).toBeTruthy();
    });

  });


  describe('collectItemIds', function() {
    it ('collects item IDs from an order into an array assigned to scope', function() {
      var order = {
        "id": 1,
        "items": [
          { "id": 1 },
          { "id": 2 },
          { "id": 3 }
        ]
      }
      circaCtrl.collectItemIds($scope, order);
      expect($scope.itemIds).toEqual( [1,2,3] )
    });
  });


  describe('goto', function() {
    it('changes location to specified path', function() {
      circaCtrl.goto('test/1');
      expect($location.path()).toBe('/test/1');
    });
  });

  describe('showItem', function() {
    it('uses goto to change location', function() {
      $scope.showItem(1);
      expect($location.path()).toBe('/items/1');
    });
  });

  describe('showItemHistory', function() {
    it('', function() {
      $scope.showItemHistory(1);
      expect($location.path()).toBe('/items/1/history');
    });
  });

  describe('showOrder', function() {
    it('uses goto to change location', function() {
      $scope.showOrder(1);
      expect($location.path()).toBe('/orders/1');
    });
  });

  describe('editOrder', function() {
    it('uses goto to change location', function() {
      $scope.editOrder(1);
      expect($location.path()).toBe('/orders/1/edit');
    });
  });

  describe('showLocation', function() {
    it('uses goto to change location', function() {
      $scope.showLocation(1);
      expect($location.path()).toBe('/locations/1');
    });
  });

  describe('editLocation', function() {
    it('uses goto to change location', function() {
      $scope.editLocation(1);
      expect($location.path()).toBe('/locations/1/edit');
    });
  });

  describe('setStatesEvents', function() {
    var statesEvents = [
      [ 'state0', 'event0' ],
      [ 'state1', 'event1' ],
      [ 'state2', 'event2' ]
    ]

    beforeEach(function() {
      $scope.order = {
        id: 1,
        states_events: statesEvents,
        current_state: 'state1',
        available_events: ['event2'],
        permitted_events: ['event2']
      }
      circaCtrl.setStatesEvents($scope);
    });

    it('defines $scope.statesEvents', function() {
      expect($scope.statesEvents).toBeDefined();
    });

    it('identified complete events based on current state', function() {
      expect($scope.statesEvents[0]['complete']).toBeDefined();
      expect($scope.statesEvents[0]['complete']).toBe(true);
      expect($scope.statesEvents[1]['complete']).toBe(true);
      expect($scope.statesEvents[2]['complete']).toBe(false);
    });
  });


  describe('collectUserEmails', function() {
    var order = {
      "users": [
        { "email": "email1@foo.com" },
        { "email": "email2@foo.com" },
        { "email": "email3@foo.com" }
      ]
    };
    it("collects user emails from order into an array assigned to scope", function() {
      circaCtrl.collectUserEmails($scope, order);
      expect($scope.userEmails).toBeDefined();
      expect($scope.userEmails).toEqual( ["email1@foo.com","email2@foo.com","email3@foo.com"] );
    });
  });



  describe('collectAssigneeEmails', function() {
    var order = {
      "assignees": [
        { "email": "email1@foo.com" },
        { "email": "email2@foo.com" },
        { "email": "email3@foo.com" }
      ]
    };
    it("collects assignee emails from order into an array assigned to scopee", function() {
      circaCtrl.collectAssigneeEmails($scope, order);
      expect($scope.assigneeEmails).toBeDefined();
      expect($scope.assigneeEmails).toEqual( ["email1@foo.com","email2@foo.com","email3@foo.com"] );
    });
  });





  describe('updateOrder', function() {
    it("IS PENDING", function() {
      pending();
    });
  });


  describe('triggerOrderEvent', function() {
    it('uses apiRequests service to trigger event', function() {
      circaCtrl.triggerOrderEvent($scope, 1, 'event');
      expect(apiRequestsStub.put.calledOnce).toBeTruthy();
    });
    it('is also available to $scope', function() {
      $scope.triggerOrderEvent($scope, 1, 'event');
      expect(apiRequestsStub.put.calledOnce).toBeTruthy();
    });
  });


  describe('triggerItemEvent', function() {
    beforeEach(function() {
      $scope.order = {
        id: 1
      }
    });
    it('uses apiRequests service to trigger event', function() {
      circaCtrl.triggerItemEvent($scope, 1, 'event');
      expect(apiRequestsStub.put.calledOnce).toBeTruthy();
    });
    it('is also available to $scope', function() {
      $scope.triggerItemEvent($scope, 1, 'event');
      expect(apiRequestsStub.put.calledOnce).toBeTruthy();
    });
  });


  describe('initializeCheckOut', function() {
    beforeEach(function() {
      $scope.order = {
        id: 1,
        users: [
          { id: 1 },
          { id: 2 }
        ]
      }
    });

    it("defines $scope.checkOutItemIds", function() {
      circaCtrl.initializeCheckOut($scope);
      expect($scope.checkOutItemIds).toBeDefined();
    });

    it("defines $scope.toggleCheckout function", function() {
      circaCtrl.initializeCheckOut($scope);
      expect($scope.toggleCheckout).toBeDefined();
    });

    it("sets availabelUsers on $scope", function() {
      circaCtrl.initializeCheckOut($scope);
      expect($scope.availableUsers).toEqual( { "1": { id: 1 }, "2": { id: 2 } })
    });

    it("auto-selects user for check out if only one on the order", function() {
      $scope.order = {
        id: 1,
        users: [ { id: 23 } ]
      };
      circaCtrl.initializeCheckOut($scope);
      expect($scope.checkOutUserIds).toEqual([23]);
    });
  });


  describe('checkOutItem, checkInItem', function() {
    beforeEach(function() {
      $scope.order = {
        id: 1,
        users: [
          { id: 1 },
          { id: 2 }
        ]
      }
    });
    it('uses apiRequests service to trigger checkout', function() {
      var item = { id: 1 };
      var userIds = [1];
      circaCtrl.checkOutItem($scope, item, userIds);
      expect(apiRequestsStub.post.calledOnce).toBeTruthy();
    });
    it('uses apiRequests service to trigger checkin', function() {
      var item = { id: 1 };
      circaCtrl.checkInItem($scope, item);
      expect(apiRequestsStub.get.calledOnce).toBeTruthy();
    });
  });


  describe('getLocation', function() {
    it('uses apiRequests service to get location', function() {
      circaCtrl.getLocation($scope, 1);
      expect(apiRequestsStub.get.calledOnce).toBeTruthy();
    });
  });


  describe('getLocations', function() {
    it('uses apiRequests service to get locations', function() {
      circaCtrl.getLocations($scope);
      expect(apiRequestsStub.getPage.calledOnce).toBeTruthy();
    });
  });


  describe('confirmDeleteRecord', function() {
    it("IS PENDING", function() {
      pending();
    });
  });


  describe('deleteRecord', function() {
    it('uses apiRequests service to delete record', function() {
      circaCtrl.deleteRecord($scope, 'order', 1);
      expect(apiRequestsStub.delete.calledOnce).toBeTruthy();
    });
  });


});
