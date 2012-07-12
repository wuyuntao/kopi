(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/ui/notification/bubbles", function(require, exports, module) {
    var Bubble, bubbleInstance, hide, instance, klass, overlays, show, text, widgets;
    klass = require("kopi/utils/klass");
    widgets = require("kopi/ui/notification/widgets");
    overlays = require("kopi/ui/notification/overlays");
    text = require("kopi/ui/text");
    Bubble = (function(_super) {

      __extends(Bubble, _super);

      Bubble.widgetName("Bubble");

      function Bubble() {
        Bubble.__super__.constructor.call(this);
        this._timer = null;
        this._overlay = overlays.instance();
        this.register("content", text.EllipsisText, {
          valign: text.EllipsisText.VALIGN_MIDDLE
        });
      }

      /*
          Update text in bubble
      */


      Bubble.prototype.text = function(text) {
        this._content.text(text, true);
        return this;
      };

      /*
          Show bubble
      
          @param {String} message text to show in the bubble
          @param {Hash} options options for bubble
      
          @option {Boolean} lock if overlay is shown
          @option {Boolean} transparent if overlay is transparent
          @option {Integer) duration bubble should disapper automatically
      */


      Bubble.prototype.show = function(message, options) {
        var cls, hideFn, self;
        if (message == null) {
          message = "";
        }
        if (options == null) {
          options = {};
        }
        cls = this.constructor;
        self = this;
        if (!self.hidden) {
          self.hide();
        }
        self.hidden = false;
        if (options.lock) {
          self._overlay.show(options.transparent);
        }
        self._content.text(message, true);
        self.element.addClass(cls.showClass());
        if (options.duration) {
          hideFn = function() {
            self.hide();
            return self._timer = null;
          };
          self._timer = setTimeout(hideFn, options.duration);
        }
        return self;
      };

      /*
          Hide bubble
      */


      Bubble.prototype.hide = function() {
        var cls, self;
        cls = this.constructor;
        self = this;
        if (self.hidden) {
          return self;
        }
        self.hidden = true;
        self._overlay.hide();
        self.element.removeClass(cls.showClass());
        if (self._timer) {
          clearTimeout(self._timer);
          self._timer = null;
        }
        return self;
      };

      return Bubble;

    })(widgets.Widget);
    bubbleInstance = null;
    instance = function() {
      return bubbleInstance || (bubbleInstance = new Bubble().skeletonTo(document.body).render());
    };
    show = function() {
      var _ref;
      return (_ref = instance()).show.apply(_ref, arguments);
    };
    hide = function() {
      return instance.hide.apply(instance, arguments);
    };
    return {
      instance: instance,
      show: show,
      hide: hide,
      Bubble: Bubble
    };
  });

}).call(this);
