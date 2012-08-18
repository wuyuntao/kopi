
/*!
Some common exceptions for Kopi

@author Wu Yuntao <wyt.brandon@gmail.com>
@license MIT
*/


(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/exceptions", function(require, exports, module) {
    /*
      Base class of all exceptions.
    
      @class
    */

    var Exception, NoSuchElementError, NotImplementedError, SingletonError, ValueError;
    Exception = (function(_super) {

      __extends(Exception, _super);

      /*
          @constructor
          @param {String} message
      */


      function Exception(message) {
        if (message == null) {
          message = "";
        }
        this.name = this.constructor.name;
        this.message = message;
      }

      return Exception;

    })(Error);
    /*
      Error raised when HTML element can not be found.
    
      @class
    */

    NoSuchElementError = (function(_super) {

      __extends(NoSuchElementError, _super);

      /*
          @constructor
          @param {Element} element
      */


      function NoSuchElementError(element) {
        var message;
        message = "Can not find element: " + element;
        NoSuchElementError.__super__.constructor.call(this, message);
      }

      return NoSuchElementError;

    })(Exception);
    /*
      Error raised when a method is not ready to use.
    
      @class
    */

    NotImplementedError = (function(_super) {

      __extends(NotImplementedError, _super);

      /*
          @constructor
          @param {String} message
      */


      function NotImplementedError(message) {
        if (message == null) {
          message = "Not implemented yet.";
        }
        NotImplementedError.__super__.constructor.call(this, message);
      }

      return NotImplementedError;

    })(Exception);
    /*
      Error raised when value is not correct.
    
      @class
    */

    ValueError = (function(_super) {

      __extends(ValueError, _super);

      function ValueError() {
        return ValueError.__super__.constructor.apply(this, arguments);
      }

      return ValueError;

    })(Exception);
    /*
      Error raised when a singleton class initialized more than once.
    
      @class
    */

    SingletonError = (function(_super) {

      __extends(SingletonError, _super);

      /*
          @constructor
          @param {Class} klass
      */


      function SingletonError(klass) {
        SingletonError.__super__.constructor.call(this, "" + klass.name + " is a singleton class.");
      }

      return SingletonError;

    })(Exception);
    return {
      /*!
      Exports exceptions
      */

      Exception: Exception,
      NoSuchElementError: NoSuchElementError,
      NotImplementedError: NotImplementedError,
      ValueError: ValueError,
      SingletonError: SingletonError
    };
  });

}).call(this);
