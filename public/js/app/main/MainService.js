
VisualMerge.service('MainService', function($http, $q) {

  var URL = 'api/files_list?count=2';

  function _getData() {
    var request = $http({
      method: 'get',
      url: URL      
    });

    return request.then(handleSuccess, handleError);
  }

  function handleSuccess(data) {
    return data.data;
  }

  function handleError(e) {
    console.log(e);
  }

  return {
    getData: _getData
  };
});