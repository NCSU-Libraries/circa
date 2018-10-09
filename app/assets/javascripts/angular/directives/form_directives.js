'use strict';

/* Directives */

var formDirectives = angular.module('formDirectives', []);


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

