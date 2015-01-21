
VisualMerge.factory('MainFactory', function() {
  var factory = {};

  var files = {
    '10/10/2014': [
      { name: 'Controller1.js', changes: 2 },
      { name: 'View1.js', changes: 7 }
    ],
    '11/10/2014': [
      { name: 'Controller2.js', changes: 4 },
      { name: 'Model2.js', changes: 5 }
    ]
  };

  factory.getFiles = function() {
    return files;
  };

  return factory;
});