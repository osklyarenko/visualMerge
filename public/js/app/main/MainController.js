
VisualMerge.controller('MainController', function($scope, $filter, $controller,  MainService) {

  var chartEl = $('#chart').get(0);
  var chartController = $scope.$new();
  $controller('ChartController', { $scope: chartController });

  $scope.change = function () {
    var data = $scope.name ? _filer($scope.chartData, $scope.name) : $scope.chartData;
    _load(data);
  };

  function _success(response) {
    $scope.chartData = response.documents;
    _load($scope.chartData);
  }

  function _error(response) {
    console.log('error:', response);
  }

  function _load(data) {
    chartController.data = data;
    chartController.render(chartEl);
  }

  function _filer(data, name) {
    return $filter('filter')(data, name, 'name');
  }

  MainService.getData().then(_success, _error);
});