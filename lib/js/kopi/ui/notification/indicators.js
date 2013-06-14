(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/ui/notification/indicators", function(require, exports, module) {
    var Indicator, hide, i18n, indicatorInstance, instance, overlays, settings, show, widgets;

    settings = require("kopi/settings");
    i18n = require("kopi/utils/i18n");
    widgets = require("kopi/ui/notification/widgets");
    overlays = require("kopi/ui/notification/overlays");
    Indicator = (function(_super) {
      __extends(Indicator, _super);

      Indicator.widgetName("Indicator");

      function Indicator() {
        Indicator.__super__.constructor.call(this);
        this._overlay = overlays.instance();
      }

      Indicator.prototype.onskeleton = function() {
        return Indicator.__super__.onskeleton.apply(this, arguments);
      };

      Indicator.prototype.show = function(options) {
        var cls, self;

        if (options == null) {
          options = {};
        }
        cls = this.constructor;
        self = this;
        if (!self.hidden) {
          return self;
        }
        if (typeof options.lock === 'undefined') {
          options.lock = true;
        }
        self.hidden = false;
        if (options.lock) {
          self._overlay.show(options.transparent);
        }
        self.element.addClass(cls.showClass());
        return self;
      };

      Indicator.prototype.hide = function() {
        var cls, self;

        cls = this.constructor;
        self = this;
        if (self.hidden) {
          return self;
        }
        self.hidden = true;
        self._overlay.hide();
        self.element.removeClass(cls.showClass());
        return self;
      };

      return Indicator;

    })(widgets.Widget);
    indicatorInstance = null;
    instance = function() {
      return indicatorInstance || (indicatorInstance = new Indicator().skeletonTo(document.body).render());
    };
    show = function() {
      return instance().show();
    };
    hide = function() {
      return instance().hide();
    };
    return {
      instance: instance,
      show: show,
      hide: hide,
      Indicator: Indicator
    };
  });

}).call(this);
