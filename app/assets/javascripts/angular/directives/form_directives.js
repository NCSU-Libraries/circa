'use strict';

/* Directives */

var formDirectives = angular.module('formDirectives', []);

// formDirectives.directive("userField", ['$compile', function ($compile) {

//   var linkFunction = function(scope, element, attributes) {
//     var field = attributes["userField"];

//     console.log(field);

//     scope.html = '';
//     scope.html += '<div ng-class="validationErrors[' + field + '] ? \'has-error\' : \'\'">';

//     switch(field) {
//       case 'first_name':
//         scope.html += '<span class="field-label">First name</span><br>';
//         scope.html += '<input type="text" ng-model="user[\'first_name\']">';
//         break;
//       case 'first_name':
//         scope.html += '<span class="field-label">Last name</span><br>';
//         scope.html += '<input type="text" ng-model="user[\'last_name\']">';
//         break;
//     }
//     scope.html += '<div ng-if="validationErrors[field]" class="validation-error field-validation-error">{{ validationErrors[field] }}</div>';
//     scope.html += '</div>';
//     scope.html = $compile(scope.html)(scope);
//   };


//   return {
//     restrict: "A",
//     template = "<div>{{ html }}</div>",
//     // template: $compile("<div>{{ html }}</div>"),
//     link: linkFunction,
//     scope: {}
//   };

// }]);



formDirectives.directive("clearUserSelect", [ function () {
  return {
    restrict: 'A',
    link: function(scope, elem, attrs) {
      // var wrapper = elem.parents('.user-select');
      elem.on('click',function() {
        var userType = attrs['clearUserSelect'];
        var id = (userType == 'assignee') ? 'assigneeSelectEmail_value' : 'userSelectEmail_value';
        var input = $('#' + id);
        $(input).val('');
      });
    }
  }
}]);



formDirectives.directive("recordSelectTrigger", [ function () {
  return {
    restrict: 'A',
    link: function(scope, elem, attrs) {

      // var wrapper = elem.parents('.user-select');
      var input = elem.find('input');
      var submit = elem.find('.button');

      $(input).on('focus', function() {
        if (this == document.activeElement) {
          $(document).on('keydown', function(event) {
            var keyCode = event.keyCode;
            if (keyCode == 13) {
              $(submit).trigger('click');
            }
          });
        }
      });
      $(input).on('blur', function() {
        $(document).off('keydown');
      });
    }
  }
}]);

