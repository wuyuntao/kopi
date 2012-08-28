(function() {

  define("kopi/utils/func", function(require, exports, module) {
    /*
      # Function utilities
      #
    */

    var isFunction, text;
    text = require("kopi/utils/text");
    /*
      ## isFunction(fn)
    
      Is the given value a function?
    
      ```coffeescript
      # return: true
      func = require "kopi/utils/func"
      func.isFunction(-> console.log("This is a function."))
    */

    isFunction = function(fn) {
      return !!(fn && fn.constructor && fn.call && fn.apply);
    };
    return {
      isFunction: isFunction
    };
  });

}).call(this);
