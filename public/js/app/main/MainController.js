
VisualMerge.controller('MainController', function($scope, $filter, $controller,  MainService) {

  var chartEl = $('#chart').get(0);
  var chartController = $scope.$new();
  $controller('ChartController', { $scope: chartController });
  $scope.params = {
    type: 'day',
    count: 1
  };

  $scope.filterChange = function () {
    var data = $scope.name ? _filer($scope.chartData, $scope.name) : $scope.chartData;
    _load(data, $scope.meta);
  };

  $scope.paramsChange = loadData;

  function loadData() {
    MainService.getData($scope.params).then(_success, _error);
  }

  function _success(response) {
    var end = response.meta.hours_range;
    chartController.setRange(0, end);

    $scope.chartData = response.documents;
    $scope.meta = response.meta;

    _load($scope.chartData, $scope.meta);
  }

  function _error(response) {
    console.log('error:', response);
  }

  function _load(data, meta) {
    chartController.documents = data; 
    chartController.meta = meta;

    chartController.render(chartEl);
  }

  function _filer(data, name) {
    return $filter('filter')(data, name, 'name');
  }

  loadData();
});