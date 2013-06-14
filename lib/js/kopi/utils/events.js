(function() {
  define("kopi/utils/events", function(require, exports, module) {
    var $, defineMethod, delta, interval, last, name, now, onResize, settings, support, throttle, _i, _len, _ref;

    $ = require("jquery");
    settings = require("kopi/settings");
    support = require("kopi/utils/support");
    exports.MOUSE_OVER_EVENT = "mouseenter";
    exports.MOUSE_DOWN_EVENT = "mousedown";
    exports.MOUSE_MOVE_EVENT = "mousemove";
    exports.MOUSE_UP_EVENT = "mouseup";
    exports.MOUSE_OUT_EVENT = "mouseleave";
    exports.ORIENTATION_CHANGE_EVENT = "orientationchange";
    exports.RESIZE_EVENT = "resize";
    exports.THROTTLED_RESIZE_EVENT = "throttledresize";
    exports.LEFT_BUTTON = 1;
    exports.MIDDLE_BUTTON = 2;
    exports.RIGHT_BUTTON = 3;
    if (support.touch) {
      exports.TOUCH_START_EVENT = "touchstart";
      exports.TOUCH_MOVE_EVENT = "touchmove";
      exports.TOUCH_END_EVENT = "touchend";
      exports.TOUCH_CANCEL_EVENT = "touchcancel";
      exports.isLeftClick = function(event) {
        return true;
      };
      exports.isRightClick = function(event) {
        return false;
      };
    } else {
      exports.TOUCH_START_EVENT = exports.MOUSE_DOWN_EVENT;
      exports.TOUCH_MOVE_EVENT = exports.MOUSE_MOVE_EVENT;
      exports.TOUCH_END_EVENT = exports.MOUSE_UP_EVENT;
      exports.TOUCH_CANCEL_EVENT = exports.MOUSE_OUT_EVENT;
      exports.isLeftClick = function(event) {
        return event.which === exports.LEFT_BUTTON;
      };
      exports.isRightClick = function(event) {
        return event.which === exports.RIGHT_BUTTON;
      };
    }
    exports.WEBKIT_TRANSITION_END_EVENT = "webkitTransitionEnd";
    /*
    Throttled resize event
    */

    throttle = 250;
    now = null;
    delta = null;
    last = 0;
    interval = null;
    onResize = function() {
      now = (new Date()).getTime();
      delta = now - last;
      if (delta >= throttle) {
        last = now;
        $(this).trigger(exports.THROTTLED_RESIZE_EVENT);
      } else {
        if (interval) {
          clearTimeout(interval);
        }
        interval = setTimeout(onResize, throttle - delta);
      }
    };
    $.event.special.throttledresize = {
      setup: function() {
        return $(this).bind(exports.RESIZE_EVENT, onResize);
      },
      teardown: function() {
        return $(this).unbind(exports.RESIZE_EVENT, onResize);
      }
    };
    defineMethod = function(name) {
      return $.fn[name] = function(fn) {
        if (fn) {
          return this.bind(name, fn);
        } else {
          return this.trigger(name);
        }
      };
    };
    _ref = [exports.THROTTLED_RESIZE_EVENT];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      name = _ref[_i];
      defineMethod(name);
    }
  });

}).call(this);
