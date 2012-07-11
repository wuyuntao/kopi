(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/tests/ui/touchable", function(require, exports, module) {
    var $, CustomGesture, PhotoGallery, Touchable, g, math;
    $ = require("jquery");
    Touchable = require("kopi/ui/touchable").Touchable;
    g = require("kopi/ui/gestures");
    math = Math;
    CustomGesture = (function(_super) {

      __extends(CustomGesture, _super);

      CustomGesture.configure({
        preventDefault: true,
        tapDistance: 20,
        dragMinDistance: 20,
        swipeTime: 200
      });

      function CustomGesture() {
        CustomGesture.__super__.constructor.apply(this, arguments);
      }

      CustomGesture.prototype.ontouchstart = function(e) {
        this._startEvent = e;
        this._startPos = this._getPosition(e);
        this._startTouches = this._getTouches(e);
        this._startTime = e.timeStamp;
        this._isTouched = true;
        this._isSingleTouched = this._startTouches === 1;
        if (this._isSingleTouched) {
          this._tapMoved = false;
        } else {
          this._isFirstPinch = true;
        }
        this._isFirstDrag = true;
        this._isDragged = false;
        this._isDragEnd = false;
        this._isPinched = false;
        return this._isPinchEnd = false;
      };

      CustomGesture.prototype.ontouchmove = function(e) {
        var angle, moveDistance, scale;
        if (!this._isTouched) {
          return false;
        }
        this._moveEvent = e;
        this._movePos = this._getPosition(e);
        this._moveTime = e.timeStamp;
        this._isSingleTouched = this._startTouches === 1;
        moveDistance = this._getDistance(this._movePos, this._startPos);
        if (this._isSingleTouched) {
          if (!this._tapMoved) {
            if (moveDistance.dist > this._options.tapDistance) {
              this._tapMoved = true;
            }
          }
        } else {
          scale = this._getScale(this._startPos, this._movePos);
          this._scalePos = {
            x: (this._movePos[0].x + this._movePos[1].x) / 2,
            y: (this._movePos[0].y + this._movePos[1].y) / 2
          };
          e.position = this._scalePos;
          e.scale = scale;
          if (this._isFirstPinch) {
            this._widget.emit("pinchstart", [e]);
            this._isFirstPinch = false;
          } else {
            this._widget.emit("pinchmove", [e]);
          }
          this._isPinched = true;
          e.preventDefault();
          e.stopPropagation();
        }
        if (moveDistance.dist > this._options.dragMinDistance) {
          angle = this._getAngleByDistance(moveDistance);
          e.angle = angle;
          e.direction = this._getDirection(angle);
          e.distance = moveDistance.dist;
          e.distanceX = moveDistance.distX;
          e.distanceY = moveDistance.distY;
          if (this._isFirstDrag) {
            this._widget.emit("dragstart", [e]);
            this._isFirstDrag = false;
          } else {
            this._widget.emit("dragmove", [e]);
          }
          this._isDragged = true;
          e.preventDefault();
          return e.stopPropagation();
        }
      };

      CustomGesture.prototype.ontouchend = function(e) {
        var angle, endDistance, scale;
        if (!this._isTouched) {
          return false;
        }
        this._endEvent = e;
        this._endPos = this._movePos;
        this._endTime = e.timeStamp;
        if (this._isSingleTouched && !this._tapMoved) {
          e.preventDefault();
          e.stopPropagation();
          this._widget.emit("tap", [e]);
          return;
        }
        if (this._endPos) {
          endDistance = this._getDistance(this._endPos, this._startPos);
        }
        if (this._isPinched && !this._isPinchEnd) {
          scale = this._getScale(this._startPos, this._endPos);
          this._scalePos = {
            x: (this._endPos[0].x + this._endPos[1].x) / 2,
            y: (this._endPos[0].y + this._endPos[1].y) / 2
          };
          e.position = this._scalePos;
          e.scale = scale;
          this._isPinchEnd = true;
          this._widget.emit("pinchend", [e]);
        }
        if (this._isDragged && !this._isDragEnd) {
          angle = this._getAngleByDistance(endDistance);
          e.angle = angle;
          e.direction = this._getDirection(angle);
          e.distance = endDistance.dist;
          e.distanceX = endDistance.distX;
          e.distanceY = endDistance.distY;
          if (this._endTime - this._startTime < this._options.swipeTime) {
            this._widget.emit("swipe", [e]);
            this._widget.emit("swipe" + e.direction, [e]);
          }
          this._isDragEnd = true;
          return this._widget.emit("dragend", [e]);
        }
      };

      CustomGesture.prototype.ontouchcancel = function(e) {
        return this.ontouchend(e);
      };

      return CustomGesture;

    })(g.Base);
    PhotoGallery = (function(_super) {

      __extends(PhotoGallery, _super);

      PhotoGallery.widgetName("PhotoGallery");

      PhotoGallery.configure({
        gestures: [CustomGesture]
      });

      function PhotoGallery() {
        PhotoGallery.__super__.constructor.apply(this, arguments);
        this.images = [];
      }

      PhotoGallery.prototype.onskeleton = function() {
        return PhotoGallery.__super__.onskeleton.apply(this, arguments);
      };

      PhotoGallery.prototype.onrender = function() {
        var _this = this;
        $("img", this.element).each(function() {
          var img;
          img = $(_this);
          img.data("width", _this.width).data("height", _this.height);
          return _this.images.push(img);
        });
        return PhotoGallery.__super__.onrender.apply(this, arguments);
      };

      PhotoGallery.prototype.ontap = function(e, event) {
        return console.log("Tap", event);
      };

      PhotoGallery.prototype.ondragstart = function(e, event) {
        return console.log("DragStart", event);
      };

      PhotoGallery.prototype.ondragmove = function(e, event) {
        return console.log("DragMove", event);
      };

      PhotoGallery.prototype.ondragend = function(e, event) {
        return console.log("DragEnd", event);
      };

      PhotoGallery.prototype.onswipe = function(e, event) {
        return console.log("Swipe", event);
      };

      PhotoGallery.prototype.onswipeleft = function(e, event) {
        return console.log("SwipeLeft", event);
      };

      PhotoGallery.prototype.onswiperight = function(e, event) {
        return console.log("SwipeRight", event);
      };

      PhotoGallery.prototype.onpinchstart = function(e, event) {
        return console.log("PinchStart: " + event.scale);
      };

      PhotoGallery.prototype.onpinchmove = function(e, event) {
        return console.log("PinchChange: " + event.scale);
      };

      PhotoGallery.prototype.onpinchend = function(e, event) {
        return console.log("PinchEnd: " + event.scale);
      };

      return PhotoGallery;

    })(Touchable);
    return $(function() {
      return new PhotoGallery().skeleton("#container").render();
    });
  });

}).call(this);
