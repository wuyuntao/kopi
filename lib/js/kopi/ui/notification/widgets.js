(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/ui/notification/widgets", function(require, exports, module) {
    var Widget, settings, text, widgets;
    settings = require("kopi/settings");
    text = require("kopi/utils/text");
    widgets = require("kopi/ui/widgets");
    /*
      Base class for notification widgets
    */

    Widget = (function(_super) {
      var action, actions, defineMethod, kls, _i, _len;

      __extends(Widget, _super);

      kls = Widget;

      kls.SHOW = "show";

      kls.HIDE = "hide";

      kls.TRANSPARENT = "transparent";

      kls.NOTIFICATION = "notification";

      kls.configure({
        prefix: "kopi-notification",
        autoSkeleton: true
      });

      actions = [kls.SHOW, kls.HIDE, kls.TRANSPARENT];

      defineMethod = function(action) {
        return kls["" + action + "Class"] = function() {
          var _name;
          return this[_name = "_" + action + "Class"] || (this[_name] = this.cssClass(action));
        };
      };

      for (_i = 0, _len = actions.length; _i < _len; _i++) {
        action = actions[_i];
        defineMethod(action);
      }

      function Widget(options) {
        var _base;
        Widget.__super__.constructor.call(this, options);
        (_base = this._options).element || (_base.element = "#" + (this.constructor.cssClass()));
        this.hidden = true;
      }

      return Widget;

    })(widgets.Widget);
    return {
      Widget: Widget
    };
  });

}).call(this);
