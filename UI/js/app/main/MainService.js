
VisualMerge.service('MainService', function($http, $q) {

  var URL = 'api/files_list';

  function _getData() {
    var request = $http({
      method: 'get',
      url: URL,
      params: {
        action: 'get'
      }
    });

    return request.then(handleSuccess, handleError);
  }

  return {
    getData: _getData
  };
});