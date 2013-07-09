(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/exceptions", function(require, exports, module) {
    /*
    # Some common exceptions for Kopi
    
    ## Exception
    
    Base class of all exceptions.
    
    ```coffeescript
    throw new Exception("Some exception")
    ```
    */

    var Exception, NoSuchElementError, NotImplementedError, SingletonError, ValueError;
    Exception = (function(_super) {

      __extends(Exception, _super);

      function Exception(message) {
        if (message == null) {
          message = "";
        }
        this.name = this.constructor.name || "Error";
        this.message = message;
      }

      return Exception;

    })(Error);
    /*
    ## NoSuchElementError
    
    Error raised when HTML element can not be found.
    
    ```coffeescript
    element = $("#container")
    throw new NoSuchElementError(element) unless element.length
    ```
    */

    NoSuchElementError = (function(_super) {

      __extends(NoSuchElementError, _super);

      function NoSuchElementError(element) {
        var message;
        message = "Can not find element: " + element;
        NoSuchElementError.__super__.constructor.call(this, message);
      }

      return NoSuchElementError;

    })(Exception);
    /*
    ## NotImplementedError
    
    Error raised when a method is not ready to use.
    */

    NotImplementedError = (function(_super) {

      __extends(NotImplementedError, _super);

      function NotImplementedError(message) {
        if (message == null) {
          message = "Not implemented yet.";
        }
        NotImplementedError.__super__.constructor.call(this, message);
      }

      return NotImplementedError;

    })(Exception);
    /*
    ## ValueError
    
    Error raised when value is not correct.
    */

    ValueError = (function(_super) {

      __extends(ValueError, _super);

      function ValueError() {
        return ValueError.__super__.constructor.apply(this, arguments);
      }

      return ValueError;

    })(Exception);
    /*
    ## SingletonError
    
    Error raised when a singleton class initialized more than once.
    
    ```coffeescript
    class Viewport
    
      # Reference of singleton instance
      this.instance = null
    
      constructor: ->
        cls = this.constructor
        throw new SingletonError(cls) if cls.instance
        cls.instance = this
    ```
    */

    SingletonError = (function(_super) {

      __extends(SingletonError, _super);

      function SingletonError(klass) {
        SingletonError.__super__.constructor.call(this, "" + klass.name + " is a singleton class.");
      }

      return SingletonError;

    })(Exception);
    return {
      Exception: Exception,
      NoSuchElementError: NoSuchElementError,
      NotImplementedError: NotImplementedError,
      ValueError: ValueError,
      SingletonError: SingletonError
    };
  });

}).call(this);
