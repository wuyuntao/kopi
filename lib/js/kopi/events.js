
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
        var _ref;
        (_ref = (this.__emitter__ || (this.__emitter__ = $(this))))[method].apply(_ref, arguments);
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
    
        view = new View()
    
      ## Add event listeners
    
      Add a listener for the event.
    
        view.on "update", (e) ->
          console.log "view is updated."
    
      Add a one-time listener for the event. This listener is invoked at most once per object.
    
        view.once "create", (e) ->
          console.log "view is created"
    
      ## Remove event listeners
    
      Remove a listener from the listener array for the specified event
    
        callback = (e) ->
          console.log "view is updated"
        view.on "update", callback
        # ...
        view.off "update", callback
    
      Remove all listeners of specified event
    
        view.off "create"
    
      Remove all listeners attached on object
    
        view.off()
    
      ## Get listeners
    
      Get attached listeners of specified event
    
        view.listeners "update"
    
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


      EventEmitter.prototype.on = proxy("bind");

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
        var _ref;
        (_ref = (this.__emitter__ || (this.__emitter__ = $(this)))).unbind.apply(_ref, arguments);
        if (arguments.length === 0) {
          delete this.__emitter__;
        }
        return this;
      };

      /*
          Returns an array of listeners for given event.
      
          @public
          @param {String} eventType
          @return {Array}
      */


      EventEmitter.prototype.listeners = function(event) {
        var events;
        if (!this.__emitter__) {
          return [];
        }
        events = this.__emitter__.data("events");
        if (!events) {
          return [];
        } else {
          return events[event] || [];
        }
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
