(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/ui/navigation", function(require, exports, module) {
    var $, Animation, Animator, Button, Nav, NavButton, Navbar, Text, Widget, app, i18n, klass, logger, logging, settings, text, utils;
    $ = require("jquery");
    app = require("kopi/app");
    settings = require("kopi/settings");
    utils = require("kopi/utils");
    i18n = require("kopi/utils/i18n");
    klass = require("kopi/utils/klass");
    text = require("kopi/utils/text");
    Text = require("kopi/ui/text").Text;
    Widget = require("kopi/ui/widgets").Widget;
    Animator = require("kopi/ui/animators").Animator;
    Animation = require("kopi/ui/animators/animations").Animation;
    Button = require("kopi/ui/buttons").Button;
    logging = require("kopi/logging");
    logger = logging.logger(module.id);
    NavButton = (function(_super) {

      __extends(NavButton, _super);

      function NavButton() {
        return NavButton.__super__.constructor.apply(this, arguments);
      }

      NavButton.widgetName("NavButton");

      NavButton.configure({
        hasIcon: false,
        url: null,
        rounded: false,
        style: false,
        size: false
      });

      NavButton.prototype.onclick = function() {
        if (this._options.url != null) {
          logger.info("[navigation:onclick] URL: " + this._options.url);
          app.instance().load(this._options.url, this._options);
        } else {
          logger.warn("[navigation:onclick] URL is not provided");
        }
        return NavButton.__super__.onclick.apply(this, arguments);
      };

      return NavButton;

    })(Button);
    /*
    A standard navbar with three parts
      1. leftButton: usually provides a backward button
      2. title: usually provides name of view
      3. rightButton: usually provides a tool or config button
    */

    Nav = (function(_super) {
      var defineMethod, kls, name, proto, _i, _len, _ref;

      __extends(Nav, _super);

      kls = Nav;

      kls.widgetName("Nav");

      proto = kls.prototype;

      defineMethod = function(name) {
        return proto["remove" + text.capitalize(name)] = function() {
          if (this["_" + name]) {
            this["_" + name].destroy();
            this["_" + name] = null;
          }
          return this;
        };
      };

      _ref = ["title", "leftButton", "rightButton"];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        klass.accessor(proto, name);
        defineMethod(name);
      }

      function Nav() {
        var cls, options;
        Nav.__super__.constructor.apply(this, arguments);
        cls = this.constructor;
        options = this._options;
        this._title = options.title && text.isString(options.title) ? new Text({
          text: options.title,
          tagName: 'h1',
          extraClass: cls.cssClass('title')
        }) : options.title;
        this._leftButton = options.leftButton;
        this._rightButton = options.rightButton;
      }

      Nav.prototype.onskeleton = function() {
        var _j, _len1, _ref1;
        _ref1 = ["left", "center", "right"];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          name = _ref1[_j];
          this["_" + name] = this._ensureWrapper(name);
        }
        if (this._title) {
          this._title.skeletonTo(this._center);
        }
        if (this._leftButton) {
          this._leftButton.skeletonTo(this._left);
        }
        if (this._rightButton) {
          this._rightButton.skeletonTo(this._right);
        }
        return Nav.__super__.onskeleton.apply(this, arguments);
      };

      Nav.prototype.onrender = function() {
        if (this._title) {
          this._title.render();
        }
        if (this._leftButton) {
          this._leftButton.render();
        }
        if (this._rightButton) {
          this._rightButton.render();
        }
        return Nav.__super__.onrender.apply(this, arguments);
      };

      Nav.prototype.ondestroy = function() {
        if (this._title) {
          this._title.destroy();
        }
        if (this._leftButton) {
          this._leftButton.destroy();
        }
        if (this._rightButton) {
          this._rightButton.destroy();
        }
        return Nav.__super__.ondestroy.apply(this, arguments);
      };

      return Nav;

    })(Widget);
    /*
    A toolbar manages all navs
    */

    Navbar = (function(_super) {
      var kls;

      __extends(Navbar, _super);

      kls = Navbar;

      kls.widgetName("Navbar");

      kls.POS_NONE = "none";

      kls.POS_TOP = "top";

      kls.POS_TOP_FIXED = "top-fixed";

      kls.POS_BOTTOM = "bottom";

      kls.POS_BOTTOM_FIXED = "bottom-fixed";

      kls.configure({
        childClass: Nav,
        position: kls.POS_NONE
      });

      function Navbar() {
        var cls, options;
        Navbar.__super__.constructor.apply(this, arguments);
        cls = this.constructor;
        options = this._options;
        if (options.position !== cls.POS_NONE) {
          options.extraClass += " " + (cls.cssClass(options.position));
        }
      }

      return Navbar;

    })(Animator);
    return {
      NavButton: NavButton,
      Navbar: Navbar,
      Nav: Nav
    };
  });

}).call(this);
