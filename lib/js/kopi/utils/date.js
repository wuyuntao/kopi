(function() {

  define("kopi/utils/date", function(require, exports, module) {
    /*
    # Date utilities
    
    This module provides some useful helpers for `Date`. Access this module by:
    
    ```coffeescript
    date = require "kopi/utils/date"
    ```
    
    ## isDate(date)
    
    Returns true if `date` is a `Date` object
    
    ```coffeescript
    # return: true
    date.isDate(new Date())
    ```
    */

    var isDate, now;
    isDate = function(date) {
      return !!(date && date.getFullYear);
    };
    /*
    ## now()
    
    Get current timestamp. It delegates to native `Date.now()` if available.
    
    ```
    # output: 1345966176838
    console.log date.now()
    ```
    */

    now = Date.now || (Date.now = function() {
      return +new Date();
    });
    return {
      isDate: isDate,
      now: now
    };
  });

}).call(this);
