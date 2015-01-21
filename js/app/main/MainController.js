
VisualMerge.controller('MainController', function($scope, MainFactory) {
  $scope.filesStack = {};

  function init_() {
    $scope.filesStack = MainFactory.getFiles();
  }

  init_();
});