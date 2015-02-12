
VisualMerge.service('MainService', function($http, $q) {

  var URL = 'api/files_list';

  function _getData(params) {
    var urlPrams = _convertParams(params);

    var request = $http({
      method: 'get',
      url: URL + urlPrams
    });

    return request.then(_success, _error);
  }

  function _success(data) {
    return data.data;
  }

  function _error(e) {
    console.log(e);
  }

  function _convertParams(params) {
    if (0 === Object.keys(params).length) return ''; //Only ECMAScript 5

    var result = '?';
    for (var key in params) {
      if (params.hasOwnProperty(key)) {
        result += (key + '=' + params[key] + '&');
      }
    }
    return result.slice(0, - 1); //Remove last '&'
  }

  return {
    getData: _getData
  };
});