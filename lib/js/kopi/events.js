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
    
    As an event-driven framework, event emitters are heavily used in Kopi.
    A `Model` emits an event when data is saved. A `View` emits an event
    when it starts.  A `Widget` emits an event when a gesture is triggered.
    All classes which emit events inherit from `EventEmitter`.
    
    `EventEmitter` is implemented as a proxy of a private jQuery object
    called `__emitter__` so that some cutstom event features like
    namespace and propagation can be used in `EventEmitter` too.
    
    ## Usage
    
    The easiest way to make a class trigger events is to extends it
    with `EventEmitter`.
    
    ```coffeescript
    EventEmitter = require("kopi/events").EventEmitter
    
    class View extends EventEmitter
    
    view = new View()
    ```
    */

    EventEmitter = (function() {
      function EventEmitter() {}

      /*
      ## eventEmitter.emit(event\[, parameters\])
      
      `eventEmitter.emit()` is implemented as a proxy function of
      `jQuery.triggerHandler()` and executes all listeners with
      supplied parameters.
      
      `event` is a string of JavaScript event type, like `click`
      or `submit`.
      
      `parameters` is an array of additional parameters to pass
      along to the event listener.
      
      See more details in [jQuery Doc](http://api.jquery.com/triggerHandler/).
      
      ```coffeescript
      view.emit "create"
      # ...
      view.emit "update", [arg1, arg2]
      ```
      */


      EventEmitter.prototype.emit = proxy("triggerHandler");

      /*
      ## eventEmitter.on(event, listener)
      
      `eventEmitter.on()` is implemented as a proxy function of
      `jQuery.bind()` and adds a listener to an event for emitter.
      
      `event` is a string contains one or more event names, like
      `click` or `submit` or `click submit`.
      
      `listener` is a function to execute each time the event is
      triggered.
      
      See more details in [jQuery Doc](http://api.jquery.com/bind/).
      
      ```coffeescript
      view.on "update", (e) ->
        console.log "view is updated."
      ```
      */


      EventEmitter.prototype.on = proxy("bind");

      /*
      ## eventEmitter.once(event, listener)
      
      `eventEmitter.once()` is implemented as a proxy function of
      `jQuery.one()` and adds a one-time listener to an event
      for emitter.
      
      `event` is a string contains one or more event names, like
      `click` or `submit` or `click submit`.
      
      `listener` is a function to execute the first time the event is
      triggered.
      
      See more details in [jQuery Doc](http://api.jquery.com/one/).
      
      ```coffeescript
      view.once "create", (e) ->
        console.log "view is created"
      ```
      */


      EventEmitter.prototype.once = proxy("one");

      /*
      ## eventEmitter.off(\[event\]\[, listener\])
      
      `eventEmitter.off()` is implemented as a proxy function of
      `jQuery.off()` and removes one or all listeners for the specified
      event.
      
      `event` is a string of JavaScript event type, like `click`
      or `submit`.
      
      `listener` is a function to attached to the emitter.
      
      See more details in [jQuery Doc](http://api.jquery.com/off/).
      
      ```coffeescript
      callback = (e) ->
        console.log "view is updated"
      view.on "update", callback
      # ...
      view.off "update", callback
      ```
      
      Remove all listeners of specified event.
      
      ```coffeescript
      view.off "create"
      ```
      
      Remove all listeners attached on object. Also it releases the
      internal `__emitter__` object to avoid memory leak.
      
      ```coffeescript
      view.off()
      ```
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
      ## eventEmitter.listeners(\[event\])
      
      Returns an array of listeners for given event.
      
      `event` is a string of JavaScript event type, like `click`
      or `submit`.
      
      ```coffeescript
      view.listeners "update"
      ```
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
      EventEmitter: EventEmitter
    };
  });

}).call(this);
