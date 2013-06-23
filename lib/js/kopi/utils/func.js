(function() {

  define("kopi/utils/func", function(require, exports, module) {
    /*
    # Function utilities
    #
    */

    var array, asyncCall, asyncParCall, isFunction, text;
    array = require("kopi/utils/array");
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
    /*
    ## asyncCall(tasks, fn[, context])
    
    ```coffeescript
    add = (a, b, done) -> done(a + b)
    multi = (c, d, done) -> done(c * d)
    methods = [
      [add, 1, 2]
      [multi, 2, 3]
    ]
    func.asyncCall methods, (results) ->
      # output: 3
      console.log results[0]
      # output: 5
      console.log results[1]
    ```
    */

    asyncCall = function(tasks, fn, context) {
      var iterFn, results;
      results = [];
      iterFn = function(args, i, done) {
        var func;
        func = args.shift();
        args.push(function() {
          results[i] = arguments;
          return done(results);
        });
        return func.apply(context, args);
      };
      array.asyncForEach(tasks, iterFn, fn);
      return tasks;
    };
    /*
    ## asyncParCall(tasks, fn[, context])
    */

    asyncParCall = function(tasks, fn, context) {
      var iterFn, results;
      results = [];
      iterFn = function(args, i, done) {
        var func;
        func = args.shift();
        args.push(function() {
          results[i] = arguments;
          return done(results);
        });
        return func.apply(context, args);
      };
      array.asyncParForEach(tasks, iterFn, fn);
      return tasks;
    };
    return {
      isFunction: isFunction
    };
  });

}).call(this);
