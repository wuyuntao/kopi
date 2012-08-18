
/*!
# Common utilities

@author Wu Yuntao <wyt.brandon@gmail.com>
@license MIT
*/


(function() {

  define("kopi/utils", function(require, exports, module) {
    var $, counter, forcePromise, guid, isPromise, isRegExp;
    $ = require("jquery");
    /*
      Generate unique ID
    
      @param  {String}  prefix
      @return {String}
    */

    counter = 0;
    guid = function(prefix) {
      if (prefix == null) {
        prefix = 'kopi';
      }
      return prefix + '-' + counter++;
    };
    /*
      Is the given value a promise object?
    
      @param  {Object}  obj
      @return {Boolean}
    */

    isPromise = function(obj) {
      return !!(obj.then && obj.done && obj.fail && obj.pipe && !obj.reject && !obj.resolve);
    };
    /*
      A helper method to convert a sync method response to promise
    
      @param  {Object}  obj
      @return {Promise}
    */

    forcePromise = function(obj) {
      var deferred;
      if (isPromise(obj)) {
        return obj;
      }
      deferred = new $.Deferred();
      if (obj === false) {
        deferred.reject();
      } else {
        deferred.resolve();
      }
      return deferred.promise();
    };
    /*
      Is the given value a regular expression?
    
      @param {RegExp} obj
      @return {Boolean}
    */

    isRegExp = function(obj) {
      return !!(obj && obj.exec && (obj.ignoreCase || obj.ignoreCase === false));
    };
    return {
      /*!
      Exports
      */

      guid: guid,
      isPromise: isPromise,
      isRegExp: isRegExp
    };
  });

}).call(this);
