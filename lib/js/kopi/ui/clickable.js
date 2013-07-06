(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/ui/clickable", function(require, exports, module) {
    var Clickable, events, logger, logging, math, touchable;
    events = require("kopi/utils/events");
    touchable = require("kopi/ui/touchable");
    logging = require("kopi/logging");
    logger = logging.logger(module.id);
    math = Math;
    /*
    A base widget responsive to click, hold, hover and other button-like behaviors
    */

    Clickable = (function(_super) {

      __extends(Clickable, _super);

      Clickable.HOVER_EVENT = "hover";

      Clickable.HOVER_OUT_EVENT = "hoverout";

      Clickable.CLICK_EVENT = "click";

      Clickable.DOUBALE_CLICK_EVENT = "doubleclick";

      Clickable.TOUCH_HOLD_EVENT = "touchhold";

      Clickable.EVENT_NAMESPACE = "clickable";

      Clickable.widgetName("Clickable");

      Clickable.configure({
        holdTime: 2000,
        moveThreshold: 10,
        ignoreClick: false,
        lockTime: 0
      });

      function Clickable() {
        var cls;
        Clickable.__super__.constructor.apply(this, arguments);
        cls = this.constructor;
        cls.HOVER_CLASS || (cls.HOVER_CLASS = cls.cssClass("hover"));
        cls.ACTIVE_CLASS || (cls.ACTIVE_CLASS = cls.cssClass("active"));
      }

      Clickable.prototype.delegate = function() {
        var clickFn, mouseOutFn, mouseOverFn, preventDefault, self, stopPropagation;
        Clickable.__super__.delegate.apply(this, arguments);
        self = this;
        preventDefault = self._options.preventDefault;
        stopPropagation = self._options.stopPropagation;
        mouseOverFn = function(e) {
          if (preventDefault) {
            e.preventDefault();
          }
          if (stopPropagation) {
            e.stopPropagation();
          }
          self.emit(Clickable.HOVER_EVENT, [e]);
          return self.element.bind(Clickable.eventName(events.MOUSE_OUT_EVENT), mouseOutFn);
        };
        mouseOutFn = function(e) {
          if (preventDefault) {
            e.preventDefault();
          }
          if (stopPropagation) {
            e.stopPropagation();
          }
          self.emit(Clickable.HOVER_OUT_EVENT, [e]);
          return self.element.unbind(Clickable.eventName(events.MOUSE_OUT_EVENT));
        };
        self.element.bind(Clickable.eventName(events.MOUSE_OVER_EVENT), mouseOverFn);
        if (self._options.ignoreClick) {
          clickFn = function(e) {
            e.preventDefault();
            return e.stopPropagation();
          };
          return self.element.bind(Clickable.eventName(events.CLICK_EVENT), clickFn).bind(Clickable.eventName(events.DOUBALE_CLICK_EVENT), clickFn);
        }
      };

      Clickable.prototype.undelegate = function() {
        Clickable.__super__.undelegate.apply(this, arguments);
        return this.element.unbind(events.MOUSE_OVER_EVENT).unbind(events.CLICK_EVENT);
      };

      Clickable.prototype.ontouchstart = function(e, event) {
        var cls, point, self;
        cls = this.constructor;
        self = this;
        self._moved = false;
        self._holded = false;
        point = self._points(event);
        self._pointX = point.pageX;
        self._pointY = point.pageY;
        point = self._points(event);
        self.element.addClass(cls.ACTIVE_CLASS);
        return self._setHoldTimeout();
      };

      Clickable.prototype.ontouchmove = function(e, event) {
        var deltaX, deltaY, point, self, threshold;
        self = this;
        threshold = self._options.moveThreshold;
        point = self._points(event);
        deltaX = point.pageX - self._pointX;
        deltaY = point.pageY - self._pointY;
        if (!self._moved && ((math.abs(deltaX) > threshold) || (math.abs(deltaY) > threshold))) {
          self._moved = true;
        }
        return self._setHoldTimeout();
      };

      Clickable.prototype.ontouchend = function(e, event) {
        var cls, self;
        cls = this.constructor;
        self = this;
        self._clearHoldTimeout();
        self.element.removeClass(cls.ACTIVE_CLASS);
        if (!self._holded && !self._moved) {
          event.preventDefault();
          event.stopPropagation();
          if (self._canEmitClickEvent()) {
            return self.emit(cls.CLICK_EVENT, [event]);
          }
        }
      };

      Clickable.prototype.ontouchcancel = function(e, event) {
        return this.emit(this.constructor.TOUCH_END_EVENT, [event]);
      };

      Clickable.prototype.onhover = function(e, event) {
        var cls, self;
        cls = this.constructor;
        self = this;
        self._hovered = true;
        return self.element.addClass(cls.HOVER_CLASS);
      };

      Clickable.prototype.onhoverout = function(e, event) {
        var cls, self;
        cls = this.constructor;
        self = this;
        self._hovered = false;
        return self.element.removeClass(cls.HOVER_CLASS);
      };

      Clickable.prototype.onclick = function(e, event) {};

      Clickable.prototype.ontouchhold = function(e, event) {
        var cls, self;
        cls = this.constructor;
        self = this;
        self._holded = true;
        return self.emit(cls.TOUCH_END_EVENT, [event]);
      };

      Clickable.prototype._reset = function() {
        var self;
        self = this;
        self._moved = false;
        self._holded = false;
        return self._clearHoldTimeout();
      };

      Clickable.prototype._setHoldTimeout = function() {
        var cls, holdFn, self;
        cls = this.constructor;
        self = this;
        if (self._holdTimer) {
          clearTimeout(self._holdTimer);
        }
        holdFn = function() {
          if (self._canEmitTouchHoldEvent()) {
            return self.emit(cls.TOUCH_HOLD_EVENT);
          }
        };
        return self._holdTimer = setTimeout(holdFn, self._options.holdTime);
      };

      Clickable.prototype._clearHoldTimeout = function() {
        var self;
        self = this;
        if (self._holdTimer) {
          clearTimeout(self._holdTimer);
          return self._holdTimer = null;
        }
      };

      Clickable.prototype._canEmitClickEvent = function() {
        var canEmit, now;
        if (!(this._options.lockTime > 0)) {
          return true;
        }
        now = new Date().getTime();
        canEmit = !(this._clickLock + this._options.lockTime > now);
        if (canEmit) {
          this._clickLock = now;
        } else {
          logger.warn("[clickable:_canEmitClickEvent] " + this + ": is locked");
        }
        return canEmit;
      };

      Clickable.prototype._canEmitTouchHoldEvent = function() {
        return this._canEmitClickEvent();
      };

      return Clickable;

    })(touchable.Touchable);
    return {
      Clickable: Clickable
    };
  });

}).call(this);
