
VisualMerge.filter('orderObjectBy', function() {
  return function(items, field, reverse) {
    var filtered = [];
    var isNumber = function(value) {
      return '[object Number]' === Object.prototype.toString.apply(value);
    };
    var isString = function(value) {
      return '[object String]' === Object.prototype.toString.apply(value);
    };

    angular.forEach(items, function(item, key) {
      item.key = key;
      filtered.push(item);
    });
    filtered.sort(function (a, b) {
      var valueA = a[field];
      var valueB = b[field];
      isString(valueA) && (valueA = valueA.toLowerCase());
      isString(valueB) && (valueB = valueB.toLowerCase());

      return (valueA > valueB ? 1 : -1);
    });
    reverse && filtered.reverse();
    return filtered;
  };
});