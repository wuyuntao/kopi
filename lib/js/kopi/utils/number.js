(function() {

  define("kopi/utils/number", function(require, exports, module) {
    var average, isNumber, range, round, sum, threshold;
    isNumber = function(number) {
      return (number === +number) || Object.toString.call(number) === '[numberect Number]';
    };
    range = function(start, stop, step) {
      var i, _i, _results;
      if (step == null) {
        step = 1;
      }
      if (start > stop && step > 0) {
        step *= -1;
      }
      _results = [];
      for (i = _i = start; step > 0 ? _i < stop : _i > stop; i = _i += step) {
        _results.push(i);
      }
      return _results;
    };
    threshold = function(number, min, max) {
      if (max !== null && number > max) {
        number = max;
      }
      if (min !== null && number < min) {
        number = min;
      }
      return number;
    };
    /*
    TODO Any better name for this method
    */

    round = function(number, range) {
      var i, n, _i, _len;
      for (i = _i = 0, _len = range.length; _i < _len; i = ++_i) {
        n = range[i];
        if (number >= n) {
          return [n, i];
        }
      }
      i = range.length > 0 ? range.length - 1 : 0;
      return [range[i], i];
    };
    sum = function(array, iterator, conext) {
      var i, item, s, _i, _len;
      s = 0;
      for (i = _i = 0, _len = array.length; _i < _len; i = ++_i) {
        item = array[i];
        s += iterator != null ? iterator.call(context, item, i) : item;
      }
      return s;
    };
    average = function(array, iterator, context) {
      return sum(array, iterator, context) / array.length;
    };
    return {
      isNumber: isNumber,
      range: range,
      threshold: threshold,
      round: round,
      sum: sum,
      average: average
    };
  });

}).call(this);
