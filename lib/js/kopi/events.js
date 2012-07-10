(function() {

  define("kopi/events", function(require, exports, module) {
    var $, EventEmitter;
    $ = require("jquery");
    /*
      A Node-style event emitter implemented via jQuery's Event API
    
      TODO Use EventEmitter of NodeJS?
    */

    EventEmitter = (function() {

      function EventEmitter() {}

      EventEmitter.prototype.on = function() {
        var _ref;
        this._emitter || (this._emitter = $(this));
        (_ref = this._emitter).bind.apply(_ref, arguments);
        return this;
      };

      EventEmitter.prototype.off = function() {
        var _ref;
        this._emitter || (this._emitter = $(this));
        (_ref = this._emitter).unbind.apply(_ref, arguments);
        return this;
      };

      EventEmitter.prototype.emit = function() {
        var _ref;
        this._emitter || (this._emitter = $(this));
        (_ref = this._emitter).triggerHandler.apply(_ref, arguments);
        return this;
      };

      EventEmitter.prototype.once = function() {
        var _ref;
        this._emitter || (this._emitter = $(this));
        (_ref = this._emitter).one.apply(_ref, arguments);
        return this;
      };

      return EventEmitter;

    })();
    return {
      EventEmitter: EventEmitter
    };
  });

}).call(this);
