(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/ui/viewswitchers", function(require, exports, module) {
    var Animator, View, ViewSwitcher, Widget, app, viewport;
    app = require("kopi/app");
    viewport = require("kopi/ui/viewport");
    Widget = require("kopi/ui/widgets").Widget;
    Animator = require("kopi/ui/animators").Animator;
    /*
      A container of widgets of view
    */

    View = (function(_super) {

      __extends(View, _super);

      View.widgetName("View");

      function View() {
        View.__super__.constructor.apply(this, arguments);
      }

      View.prototype.onrender = function() {
        viewport.instance().register(this);
        return View.__super__.onrender.apply(this, arguments);
      };

      return View;

    })(Widget);
    /*
      Widget switcher for views
    */

    ViewSwitcher = (function(_super) {
      var kls;

      __extends(ViewSwitcher, _super);

      kls = ViewSwitcher;

      kls.widgetName("ViewSwitcher");

      kls.POS_NONE = "none";

      kls.POS_TOP = "top";

      kls.POS_TOP_FIXED = "top-fixed";

      kls.POS_BOTTOM = "bottom";

      kls.POS_BOTTOM_FIXED = "bottom-fixed";

      kls.configure({
        childClass: View,
        position: kls.POS_NONE
      });

      function ViewSwitcher() {
        var cls, options;
        ViewSwitcher.__super__.constructor.apply(this, arguments);
        cls = this.constructor;
        options = this._options;
        if (options.position !== cls.POS_NONE) {
          options.extraClass += " " + (cls.cssClass(options.position));
        }
      }

      ViewSwitcher.prototype.onlock = function() {
        app.instance().lock();
        return ViewSwitcher.__super__.onlock.apply(this, arguments);
      };

      ViewSwitcher.prototype.onunlock = function() {
        app.instance().unlock();
        return ViewSwitcher.__super__.onunlock.apply(this, arguments);
      };

      return ViewSwitcher;

    })(Animator);
    return {
      View: View,
      ViewSwitcher: ViewSwitcher
    };
  });

}).call(this);
