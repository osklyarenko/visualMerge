
VisualMerge.controller('MainController', function($scope, $controller, MainService) {
  var chartEl = $('#chart').get(0);
  var chartController = $scope.$new();

  function _success(response) {
    $controller('ChartController', { $scope: chartController });
    chartController.data = API_RESPONSE_STUB; //response;
    chartController.render(chartEl);
  }

  function _error(response) {
    console.log(response);
  }

  //MainService.getData().then(_success, _error);
  _success();
});