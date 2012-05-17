// Generated by CoffeeScript 1.3.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  define("kopi/ui/touchable", function(require, exports, module) {
    var $, Touchable, doc, events, support, widgets;
    $ = require("jquery");
    events = require("kopi/utils/events");
    support = require("kopi/utils/support");
    widgets = require("kopi/ui/widgets");
    doc = $(document);
    /*
      A widget supports touch events
    */

    Touchable = (function(_super) {
      var kls;

      __extends(Touchable, _super);

      Touchable.name = 'Touchable';

      function Touchable() {
        return Touchable.__super__.constructor.apply(this, arguments);
      }

      kls = Touchable;

      kls.TOUCH_START_EVENT = "touchstart";

      kls.TOUCH_MOVE_EVENT = "touchmove";

      kls.TOUCH_END_EVENT = "touchend";

      kls.TOUCH_CANCEL_EVENT = "touchcancel";

      kls.EVENT_NAMESPACE = "touchable";

      kls.widgetName("Touchable");

      kls.configure({
        preventDefault: false,
        stopPropagation: false,
        multiTouch: false
      });

      Touchable.prototype.onrender = function() {
        this.delegate();
        return Touchable.__super__.onrender.apply(this, arguments);
      };

      Touchable.prototype.delegate = function() {
        var cls, preventDefault, self, stopPropagation, touchCancelFn, touchEndFn, touchMoveFn, touchStartFn;
        cls = this.constructor;
        self = this;
        preventDefault = self._options.preventDefault;
        stopPropagation = self._options.stopPropagation;
        touchMoveFn = function(e) {
          if (preventDefault) {
            e.preventDefault();
          }
          if (stopPropagation) {
            e.stopPropagation();
          }
          return self.emit(cls.TOUCH_MOVE_EVENT, [e]);
        };
        touchEndFn = function(e) {
          if (preventDefault) {
            e.preventDefault();
          }
          if (stopPropagation) {
            e.stopPropagation();
          }
          doc.unbind(kls.eventName(events.TOUCH_MOVE_EVENT)).unbind(kls.eventName(events.TOUCH_END_EVENT)).unbind(kls.eventName(events.TOUCH_CANCEL_EVENT));
          return self.emit(cls.TOUCH_END_EVENT, [e]);
        };
        touchCancelFn = function(e) {
          if (preventDefault) {
            e.preventDefault();
          }
          if (stopPropagation) {
            e.stopPropagation();
          }
          doc.unbind(kls.eventName(events.TOUCH_MOVE_EVENT)).unbind(kls.eventName(events.TOUCH_END_EVENT)).unbind(kls.eventName(events.TOUCH_CANCEL_EVENT));
          return self.emit(cls.TOUCH_CANCEL_EVENT, [e]);
        };
        touchStartFn = function(e) {
          if (self.locked || !events.isLeftClick(e)) {
            return;
          }
          if (preventDefault) {
            e.preventDefault();
          }
          if (stopPropagation) {
            e.stopPropagation();
          }
          self.emit(cls.TOUCH_START_EVENT, [e]);
          return doc.bind(kls.eventName(events.TOUCH_MOVE_EVENT), touchMoveFn).bind(kls.eventName(events.TOUCH_END_EVENT), touchEndFn).bind(kls.eventName(events.TOUCH_CANCEL_EVENT), touchCancelFn);
        };
        return self.element.bind(events.TOUCH_START_EVENT, touchStartFn);
      };

      /*
          Get point from event
      */


      Touchable.prototype._points = function(event) {
        var touches;
        event = event.originalEvent;
        if (support.touch) {
          touches = event.type === events.TOUCH_END_EVENT ? event.changedTouches : event.touches;
          if (this._options.multiTouch) {
            return touches;
          } else {
            return touches[0];
          }
        } else {
          if (this._options.multiTouch) {
            return [event];
          } else {
            return event;
          }
        }
      };

      return Touchable;

    })(widgets.Widget);
    return {
      Touchable: Touchable
    };
  });

}).call(this);