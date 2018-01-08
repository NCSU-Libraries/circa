describe('ItemsCtrl', function () {

  // Initialize vars
  var $scope;
  var $controller;
  var $location;
  var apiRequestsStub;
  var itemsCtrl;

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


    itemsCtrl = $controller('ItemsCtrl', {
      '$scope': $scope,
      'apiRequests': apiRequestsStub,
      'commonUtils': commonUtilsStub
    });

  }));


  describe('getItems', function() {

    it('uses apiRequests service to get page of items', function() {
      itemsCtrl.getItems($scope);
      expect(apiRequestsStub.getPage.calledOnce).toBeTruthy();
    });

  });


  describe('getItem', function() {

    it('uses apiRequests service to get single item', function() {
      itemsCtrl.getItem($scope);
      expect(apiRequestsStub.get.calledOnce).toBeTruthy();
    });

  });


  describe('getItemMovementHistory', function() {

    it('uses apiRequests service to get item history', function() {
      itemsCtrl.getItemMovementHistory($scope);
      expect(apiRequestsStub.get.calledOnce).toBeTruthy();
    });

  });





});
