(function() {

  define("kopi/utils", function(require, exports, module) {
    var $, counter, guid, isRegExp;
    $ = require("jquery");
    /*
    # Common utilities
    
    ## guid([prefix])
    
    Generate unique ID.
    
    `prefix` is a string to make guid more readable. If not specified,
    "kopi" will be used as default.
    
    ```coffeescript
    class View
      constructor: ->
        cls = this.constructor
        # Generate guid by class name: "view-1"
        this.guid = utils.guid(text.dasherize(cls.name))
    
    ```
    */

    counter = 0;
    guid = function(prefix) {
      if (prefix == null) {
        prefix = 'kopi';
      }
      return prefix + '-' + counter++;
    };
    /*
    ## isRegExp(regexp)
    
    Check if the given value is a regular expression.
    */

    isRegExp = function(obj) {
      return !!(obj && obj.exec && (obj.ignoreCase || obj.ignoreCase === false));
    };
    return {
      guid: guid,
      isRegExp: isRegExp
    };
  });

}).call(this);
