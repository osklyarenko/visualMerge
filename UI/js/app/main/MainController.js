
VisualMerge.controller('MainController', function($scope, $controller) {
  var chartEl = $('#chart').get(0);
  var chartController = $scope.$new();
  $controller('ChartController', { $scope: chartController });

  chartController.setData(API_RESPONSE_STUB);
  chartController.render(chartEl);
});