// Generated by CoffeeScript 1.3.1
(function() {

  define("kopi/utils/date", function(require, exports, module) {
    var isDate, now;
    isDate = function(date) {
      return !!(date && date.getFullYear);
    };
    now = Date.now || (Date.now = function() {
      return +new Date();
    });
    return {
      isDate: isDate,
      now: now
    };
  });

}).call(this);
