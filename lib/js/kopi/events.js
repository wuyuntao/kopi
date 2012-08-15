
/*!
# A Node.js-style event emitter implemented via jQuery's Event API.

@author Wu Yuntao <wyt.brandon@gmail.com>
@license MIT
*/


(function() {

  define("kopi/events", function(require, exports, module) {
    var $, EventEmitter, proxy;
    $ = require("jquery");
    proxy = function(method) {
      return function() {
        (this.__emitter__ || (this.__emitter__ = $(this)))[method].apply(this, arguments);
        return this;
      };
    };
    /*
    
      # EventEmitter
    
      As an event-driven framework, event emitters are heavily used in Kopi. A `Model`
      emits an event when data is saved. A `View` emits an event when it starts.
      A `Widget` emits an event when a gesture is triggered. All classes which emit
      events inherit from `EventEmitter`.
    
      `EventEmitter` is implemented as a proxy of a private jQuery object called
      `__emitter__` so that some cutstom event features like namespace and propagation
      can be used in `EventEmitter` too.
    
      ## Usage
    
      The easiest way to make a class trigger events is to extends it with `EventEmitter`.
    
        EventEmitter = require("kopi/events").EventEmitter
    
        class View extends EventEmitter
    
      @class
    */

    EventEmitter = (function() {

      function EventEmitter() {}

      /*
          A proxy function for `jQuery.triggerHandler()`
      
          See more details in jQuery Doc. http://api.jquery.com/triggerHandler/
      
          @public
          @param {String} eventType
          @param {Array} extraParameters
          @return {EventEmitter}
      */


      EventEmitter.prototype.emit = proxy("triggerHandler");

      /*
          A proxy function for `jQuery.on()`
      
          See more details in jQuery Doc. http://api.jquery.com/on/
      
          @public
          @param {String} eventType
          @param {Function} eventHandler
          @return {EventEmitter}
      */


      EventEmitter.prototype.on = proxy("on");

      /*
          A proxy function for `jQuery.one()`.
      
          See more details in jQuery Doc. http://api.jquery.com/one/
      
          @public
          @param {String} eventType
          @param {Function} eventHandler
          @return {EventEmitter}
      */


      EventEmitter.prototype.once = proxy("one");

      /*
          A proxy function for `jQuery.off()`.
      
          Additionally, `EventEmitter` will release the internal `__emitter__` object
          if you remove all event listeners by using 'eventEmitter.off()'.
      
          See more details in jQuery Doc. http://api.jquery.com/off/
      
          @public
          @param {String} eventType
          @return {EventEmitter}
      */


      EventEmitter.prototype.off = function() {
        (this.__emitter__ || (this.__emitter__ = $(this))).off.apply(this, arguments);
        if (arguments.length === 0) {
          delete this.__emitter__;
        }
        return this;
      };

      return EventEmitter;

    })();
    return {
      /*!
      Exports `EventEmitter`
      */

      EventEmitter: EventEmitter
    };
  });

}).call(this);
