(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/ui/touchable", function(require, exports, module) {
    var $, Map, Touchable, doc, events, logger, logging, math, support, widgets;
    $ = require("jquery");
    events = require("kopi/utils/events");
    support = require("kopi/utils/support");
    widgets = require("kopi/ui/widgets");
    Map = require("kopi/utils/structs/map").Map;
    logging = require("kopi/logging");
    logger = logging.logger(module.id);
    doc = $(document);
    math = Math;
    /*
    A widget supports touch events
    */

    Touchable = (function(_super) {

      __extends(Touchable, _super);

      Touchable.TOUCH_START_EVENT = "touchstart";

      Touchable.TOUCH_MOVE_EVENT = "touchmove";

      Touchable.TOUCH_END_EVENT = "touchend";

      Touchable.TOUCH_CANCEL_EVENT = "touchcancel";

      Touchable.EVENT_NAMESPACE = "touchable";

      Touchable.DIRECTION_UP = "up";

      Touchable.DIRECTION_DOWN = "down";

      Touchable.DIRECTION_LEFT = "left";

      Touchable.DIRECTION_RIGHT = "right";

      /*
      Calculate the angle between two points
      
      @param {Object} pos1 { x: int, y: int }
      @param {Object} pos2 { x: int, y: int }
      @return {Number} angle
      */


      Touchable.angle = function(pos1, pos2) {
        var distance;
        distance = this.distance(pos1, pos2);
        return this.angleByDistance(distance);
      };

      /*
      Calculate the angle between two points via their distance
      
      @param {Object} distance { distX: int, distY: int }
      @return {Number} angle
      */


      Touchable.angleByDistance = function(distance) {
        return math.atan2(distance.distY, distance.distX) * 180 / math.PI;
      };

      /*
      Calculate the scale size between two fingers
      
      @param {Object} pos1 { x: int, y: int }
      @param {Object} pos2 { x: int, y: int }
      @return {Number} scale
      */


      Touchable.scale = function(pos1, pos2) {
        var endDistance, startDistance, x, y;
        if (pos1.length >= 2 && pos2.length >= 2) {
          x = pos1[0].x - pos1[1].x;
          y = pos1[0].y - pos1[1].y;
          startDistance = math.sqrt((x * x) + (y * y));
          x = pos2[0].x - pos2[1].x;
          y = pos2[0].y - pos2[1].y;
          endDistance = math.sqrt((x * x) + (y * y));
          return endDistance / startDistance;
        }
        return 0;
      };

      /*
      calculate mean center of multiple positions
      */


      Touchable.center = function(positions) {
        var pos, sumX, sumY, _i, _len;
        if (positions.length <= 1) {
          return positions[0];
        }
        sumX = 0;
        sumY = 0;
        for (_i = 0, _len = positions.length; _i < _len; _i++) {
          pos = positions[_i];
          sumX += pos.x;
          sumY += pos.y;
        }
        return {
          x: sumX / positions.length,
          y: sumY / positions.length
        };
      };

      /*
      calculate the rotation degrees between two fingers
      
      @param {Object} pos1 { x: int, y: int }
      @param {Object} pos2 { x: int, y: int }
      @return {Number} rotation
      */


      Touchable.rotation = function(pos1, pos2) {
        var endRotation, startRotation, x, y;
        if (pos1.length === 2 && pos2.length === 2) {
          x = pos1[0].x - pos1[1].x;
          y = pos1[0].y - pos1[1].y;
          startRotation = math.atan2(y, x) * 180 / math.PI;
          x = pos2[0].x - pos2[1].x;
          y = pos2[0].y - pos2[1].y;
          endRotation = math.atan2(y, x) * 180 / math.PI;
          return endRotation - startRotation;
        }
        return 0;
      };

      /*
      Get the angle to direction define
      
      @param {Number} angle
      @return {String} direction
      */


      Touchable.direction = function(angle) {
        if (angle >= 45 && angle < 135) {
          return this.DIRECTION_DOWN;
        } else if (angle >= 135 || angle <= -135) {
          return this.DIRECTION_LEFT;
        } else if (angle < -45 && angle > -135) {
          return this.DIRECTION_UP;
        } else {
          return this.DIRECTION_RIGHT;
        }
      };

      /*
      Calculate average distance between to points
      
      @param {Object}  pos1 { x: int, y: int }
      @param {Object}  pos2 { x: int, y: int }
      */


      Touchable.distance = function(pos1, pos2) {
        var i, len, pos1i, pos2i, sum, sumX, sumY, x, y, _i;
        sumX = 0;
        sumY = 0;
        sum = 0;
        len = math.min(pos1.length, pos2.length);
        for (i = _i = 0; 0 <= len ? _i < len : _i > len; i = 0 <= len ? ++_i : --_i) {
          pos1i = pos1[i];
          pos2i = pos2[i];
          x = pos2i.x - pos1i.x;
          y = pos2i.y - pos1i.y;
          sumX += x;
          sumY += y;
          sum += math.sqrt(x * x + y * y);
        }
        return {
          distX: sumX / len,
          distY: sumY / len,
          dist: sum / len
        };
      };

      Touchable.distanceX = function(pos1, pos2) {
        return math.abs(pos1.x - pos2.x);
      };

      Touchable.distanceY = function(pos1, pos2) {
        return math.abs(pos1.y - pos2.y);
      };

      /*
      get the x and y positions from the event object
      
      @param {Event} event
      @return {Array}  [{ x: int, y: int }]
      */


      Touchable.position = function(e, target) {
        var pos, posX, posY, touch, touches, _ref;
        if (target == null) {
          target = $(e.currentTarget);
        }
        _ref = target.offset(), posX = _ref.left, posY = _ref.top;
        if (!support.touch) {
          pos = [
            {
              x: e.pageX - posX,
              y: e.pageY - posY
            }
          ];
        } else {
          e = e ? e.originalEvent : win.event;
          touches = e.touches.length > 0 ? e.touches : e.changedTouches;
          pos = (function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = touches.length; _i < _len; _i++) {
              touch = touches[_i];
              _results.push({
                x: touch.pageX - posX,
                y: touch.pageY - posY
              });
            }
            return _results;
          })();
        }
        return pos;
      };

      Touchable.points = function(e) {
        e = e && e.originalEvent ? e.originalEvent : win.event;
        if (support.touch) {
          if (e.type === events.TOUCH_END_EVENT) {
            return e.changedTouches;
          } else {
            return e.touches;
          }
        } else {
          return [e];
        }
      };

      /*
      Count the number of fingers in the event
      when no fingers are detected, one finger is returned (mouse pointer)
      
      @param {Event} event
      @return {Number}
      */


      Touchable.fingers = function(e) {
        e = e && e.originalEvent ? e.originalEvent : win.event;
        if (e.touches) {
          return e.touches.length;
        } else {
          return 1;
        }
      };

      Touchable.widgetName("Touchable");

      Touchable.configure({
        preventDefault: false,
        stopPropagation: false,
        gestures: []
      });

      function Touchable() {
        var gesture, options, _i, _len, _ref;
        Touchable.__super__.constructor.apply(this, arguments);
        options = this._options;
        this._gestures = new Map();
        _ref = options.gestures;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          gesture = _ref[_i];
          this.addGesture(new gesture(this, options));
        }
        return;
      }

      Touchable.prototype.onrender = function() {
        this.delegate();
        return Touchable.__super__.onrender.apply(this, arguments);
      };

      Touchable.prototype.ondestroy = function() {
        this.undelegate();
        return Touchable.__super__.ondestroy.apply(this, arguments);
      };

      Touchable.prototype.delegate = function() {
        var touchCancelFn, touchEndFn, touchMoveFn, touchStartFn,
          _this = this;
        touchMoveFn = function(e) {
          return _this.emit(Touchable.TOUCH_MOVE_EVENT, [e]);
        };
        touchEndFn = function(e) {
          doc.unbind(Touchable.eventName(events.TOUCH_MOVE_EVENT)).unbind(Touchable.eventName(events.TOUCH_END_EVENT)).unbind(Touchable.eventName(events.TOUCH_CANCEL_EVENT));
          return _this.emit(Touchable.TOUCH_END_EVENT, [e]);
        };
        touchCancelFn = function(e) {
          doc.unbind(Touchable.eventName(events.TOUCH_MOVE_EVENT)).unbind(Touchable.eventName(events.TOUCH_END_EVENT)).unbind(Touchable.eventName(events.TOUCH_CANCEL_EVENT));
          return _this.emit(Touchable.TOUCH_CANCEL_EVENT, [e]);
        };
        touchStartFn = function(e) {
          _this.emit(Touchable.TOUCH_START_EVENT, [e]);
          return doc.bind(Touchable.eventName(events.TOUCH_MOVE_EVENT), touchMoveFn).bind(Touchable.eventName(events.TOUCH_END_EVENT), touchEndFn).bind(Touchable.eventName(events.TOUCH_CANCEL_EVENT), touchCancelFn);
        };
        this.element.bind(events.TOUCH_START_EVENT, touchStartFn);
        return logger.log("[touchable:delegate] " + this);
      };

      Touchable.prototype.undelegate = function() {
        this.element.unbind(events.TOUCH_START_EVENT);
        return logger.log("[touchable:undelegate] " + this);
      };

      Touchable.prototype.addGesture = function(gesture) {
        this._gestures.set(gesture.guid, gesture);
        return gesture;
      };

      Touchable.prototype.removeGesture = function(gesture) {
        this._gestures.remove(gesture.guid);
        return gesture;
      };

      Touchable.prototype.ontouchstart = function(e, event) {
        return this._callGestures(this.constructor.TOUCH_START_EVENT, event);
      };

      Touchable.prototype.ontouchmove = function(e, event) {
        return this._callGestures(this.constructor.TOUCH_MOVE_EVENT, event);
      };

      Touchable.prototype.ontouchend = function(e, event) {
        return this._callGestures(this.constructor.TOUCH_END_EVENT, event);
      };

      Touchable.prototype.ontouchcancel = function(e, event) {
        return this._callGestures(this.constructor.TOUCH_CANCEL_EVENT, event);
      };

      Touchable.prototype._callGestures = function(name, event) {
        this._gestures.forEach(function(key, gesture) {
          var method;
          method = gesture["on" + name];
          if (method) {
            if (method) {
              return method.call(gesture, event);
            }
          }
        });
      };

      /*
      Get point from event
      */


      Touchable.prototype._points = function(event) {
        var cls, points;
        cls = this.constructor;
        points = cls.points(event);
        return (this._options.multitouch ? points : points[0]);
      };

      return Touchable;

    })(widgets.Widget);
    return {
      Touchable: Touchable
    };
  });

}).call(this);
