(function() {
  var __slice = [].slice;

  define("kopi/utils/func", function(require, exports, module) {
    var isFunction, send, text;
    text = require("kopi/utils/text");
    isFunction = function(fn) {
      return !!(fn && fn.constructor && fn.call && fn.apply);
    };
    send = function() {
      var args, context, fn;
      fn = arguments[0], context = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      if (!isFunction(fn)) {
        return fn;
      }
      return fn.apply(context, args);
    };
    return {
      isFunction: isFunction,
      send: send
    };
  });

}).call(this);
