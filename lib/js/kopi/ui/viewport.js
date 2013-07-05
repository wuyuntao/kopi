(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/ui/viewport", function(require, exports, module) {
    var $, THROTTLED_RESIZE_EVENT, Viewport, browser, exceptions, klass, logger, logging, notification, widgets, win;
    $ = require("jquery");
    exceptions = require("kopi/exceptions");
    logging = require("kopi/logging");
    browser = require("kopi/utils/browser");
    widgets = require("kopi/ui/widgets");
    notification = require("kopi/ui/notification");
    klass = require("kopi/utils/klass");
    THROTTLED_RESIZE_EVENT = require("kopi/utils/events").THROTTLED_RESIZE_EVENT;
    win = $(window);
    logger = logging.logger(module.id);
    /*
    Viewport is reponsive to size changes of window
    */

    Viewport = (function(_super) {

      __extends(Viewport, _super);

      Viewport.RESIZE_EVENT = "resize";

      Viewport.widgetName("Viewport");

      Viewport.configure({
        lockWhenResizing: true
      });

      klass.singleton(Viewport);

      function Viewport() {
        var _base;
        this._isSingleton();
        Viewport.__super__.constructor.call(this);
        (_base = this._options).element || (_base.element = "body");
        this.width = null;
        this.height = null;
        this._listeners = {};
      }

      /*
      
      @param {kopi.ui.Widget} widget
      @param {Boolean}        emit   Trigger resize event right after widget is registered
      */


      Viewport.prototype.register = function(widget) {
        logger.info("[viewport:register] " + (widget.toString()) + " is registered.");
        this._listeners[widget.guid] = widget;
        return this;
      };

      Viewport.prototype.unregister = function(widget) {
        logger.info("[viewport:unregister] " + (widget.toString()) + " is unregistered.");
        delete this._listeners[widget.guid];
        return this;
      };

      Viewport.prototype.onskeleton = function() {
        var cls, self;
        cls = this.constructor;
        self = this;
        self._browser();
        self._resize(false);
        win.bind(THROTTLED_RESIZE_EVENT, function() {
          return self.emit(cls.RESIZE_EVENT);
        });
        return Viewport.__super__.onskeleton.apply(this, arguments);
      };

      Viewport.prototype.onresize = function() {
        var cls, self;
        self = this;
        cls = this.constructor;
        return self._resize(self._options.lockWhenResizing);
      };

      /*
      Widgets which is reponsive to window size, should register itself to viewport.
      When viewport receives window resize event, it will pass event to registered
      widgets properly
      */


      Viewport.prototype._resize = function(lock) {
        var cls, guid, height, self, widget, width, _ref, _ref1;
        if (lock == null) {
          lock = false;
        }
        self = this;
        cls = this.constructor;
        _ref = [win.width(), win.height()], width = _ref[0], height = _ref[1];
        if (!(width > 0 && height > 0 && self.isSizeChanged(width, height))) {
          return;
        }
        logger.info("[viewport:_resize] Resize viewport to " + width + "x" + height);
        if (lock) {
          notification.loading();
        }
        self.lock();
        self.element.width(width).height(height);
        self.width = width;
        self.height = height;
        _ref1 = self._listeners;
        for (guid in _ref1) {
          widget = _ref1[guid];
          widget.emit(cls.RESIZE_EVENT);
        }
        self.unlock();
        if (lock) {
          return notification.loaded();
        }
      };

      /*
      Check if size is different from last time
      */


      Viewport.prototype.isSizeChanged = function(width, height) {
        return width !== this.width || height !== this.height;
      };

      /*
      Add browser identify classes to viewport element
      */


      Viewport.prototype._browser = function() {
        var classes, key;
        classes = ((function() {
          var _i, _len, _ref, _results;
          _ref = browser.all;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            key = _ref[_i];
            if (browser[key]) {
              _results.push(key);
            }
          }
          return _results;
        })()).join(" ");
        return this.element.addClass(classes);
      };

      return Viewport;

    })(widgets.Widget);
    return {
      Viewport: Viewport,
      instance: function() {
        return Viewport.instance() || new Viewport();
      }
    };
  });

}).call(this);
