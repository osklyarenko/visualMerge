var VisualMerge = angular.module('VisualMerge', ['ngRoute']);

VisualMerge.config(function($routeProvider) {
  $routeProvider
    .when('/main', {
      controller: 'MainController',
      templateUrl: 'js/app/main/MainTemplate.html'
    })
    .otherwise({
      redirectTo: '/main'
    });
});

VisualMerge.run(function($rootScope, $location) {
  $rootScope.go = function(path) {
    $location.path(path);
  };
});