(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/ui/buttons", function(require, exports, module) {
    var $, AjaxButton, AsyncButton, Button, Clickable, Image, Text, exceptions, klass;
    $ = require("jquery");
    exceptions = require("kopi/exceptions");
    klass = require("kopi/utils/klass");
    Image = require("kopi/ui/images").Image;
    Text = require("kopi/ui/text").Text;
    Clickable = require("kopi/ui/clickable").Clickable;
    /*
      Button
    */

    Button = (function(_super) {
      var kls, proto;

      __extends(Button, _super);

      kls = Button;

      kls.ICON_POS_TOP = "top";

      kls.ICON_POS_RIGHT = "right";

      kls.ICON_POS_BOTTOM = "bottom";

      kls.ICON_POS_LEFT = "left";

      kls.widgetName("Button");

      kls.configure({
        hasIcon: false,
        hasText: true,
        iconPos: kls.ICON_POS_LEFT,
        rounded: true,
        cssClass: "",
        iconClass: Image,
        titleClass: Text,
        style: "default",
        size: "normal"
      });

      proto = kls.prototype;

      klass.accessor(proto, "icon", {
        set: function(icon) {
          if (this._options.hasIcon) {
            this._icon.image(icon);
          }
          return this;
        }
      });

      klass.accessor(proto, "title", {
        set: function(text) {
          if (this._options.hasText) {
            this._title.text(text);
          }
          return this;
        }
      });

      function Button(options) {
        var cls, iconOptions, self, titleOptions;
        Button.__super__.constructor.apply(this, arguments);
        cls = this.constructor;
        self = this;
        options = self._options;
        if (options.hasIcon) {
          iconOptions = self._extractOptions("icon");
          iconOptions.extraClass || (iconOptions.extraClass = "");
          iconOptions.extraClass += " " + (cls.cssClass("icon"));
          self._icon = new options.iconClass(iconOptions);
        }
        if (options.hasText) {
          titleOptions = self._extractOptions("title");
          titleOptions.extraClass || (titleOptions.extraClass = "");
          titleOptions.extraClass += " " + (cls.cssClass("title"));
          self._title = new options.titleClass(titleOptions);
        }
        if (options.rounded) {
          options.extraClass += " " + (cls.cssClass('rounded'));
        }
        if (options.style) {
          options.extraClass += " " + (cls.cssClass(options.style));
        }
        if (options.size) {
          options.extraClass += " " + (cls.cssClass(options.size));
        }
      }

      Button.prototype.onskeleton = function() {
        var cls, options, self, wrapper;
        cls = this.constructor;
        self = this;
        options = self._options;
        wrapper = self._ensureWrapper('inner');
        if (options.hasIcon) {
          self._icon.skeletonTo(wrapper);
        }
        if (options.hasText) {
          self._title.skeletonTo(wrapper);
        }
        if (options.hasIcon && options.hasText && options.iconPos === cls.ICON_POS_RIGHT || options.iconPos === cls.ICON_BOTTOM) {
          self._icon.element.insertAfter(self._title.element);
        }
        self.state("icon-pos", options.iconPos);
        return Button.__super__.onskeleton.apply(this, arguments);
      };

      Button.prototype.onrender = function() {
        var options, self;
        self = this;
        options = self._options;
        if (options.hasIcon) {
          self._icon.render();
        }
        if (options.hasText) {
          self._title.render();
        }
        return Button.__super__.onrender.apply(this, arguments);
      };

      Button.prototype.onupdate = function() {
        var options, self;
        self = this;
        options = self._options;
        if (options.hasIcon) {
          self._icon.update();
        }
        if (options.hasText) {
          self._title.update();
        }
        return Button.__super__.onupdate.apply(this, arguments);
      };

      Button.prototype.ondestroy = function() {
        var options, self;
        self = this;
        options = self._options;
        if (options.hasIcon) {
          self._icon.destroy();
        }
        if (options.hasText) {
          self._title.destroy();
        }
        return Button.__super__.ondestroy.apply(this, arguments);
      };

      return Button;

    })(Clickable);
    /*
      A button which does a asynchronic job like AJAX request, or WebSQL request when clicked
    */

    AsyncButton = (function(_super) {
      var kls;

      __extends(AsyncButton, _super);

      kls = AsyncButton;

      kls.JOB_START_EVENT = "jobstart";

      kls.JOB_SUCCEED_EVENT = "jobsucceed";

      kls.JOB_FAIL_EVENT = "jobfail";

      function AsyncButton() {
        var cls;
        AsyncButton.__super__.constructor.apply(this, arguments);
        cls = this.constructor;
        cls.LOAD_CLASS || (cls.LOAD_CLASS = cls.cssClass("load"));
        cls.SUCCEED_CLASS || (cls.SUCCEED_CLASS = cls.cssClass("succeed"));
        cls.FAIL_CLASS || (cls.FAIL_CLASS = cls.cssClass("fail"));
      }

      AsyncButton.prototype.onjobstart = function() {
        var cls, deferred, doneFn, failFn, self;
        self = this;
        cls = this.constructor;
        self.element.addClass(cls.LOAD_CLASS);
        doneFn = function() {
          return self.emit(cls.JOB_SUCCEED_EVENT, arguments);
        };
        failFn = function() {
          return self.emit(cls.JOB_FAIL_EVENT, arguments);
        };
        deferred = this._options.deferredExecute || this._deferredExecute;
        if (deferred) {
          return deferred().done(doneFn).failFn(failFn);
        } else {
          return (this._options.execute || this._execute)(failFn, doneFn);
        }
      };

      AsyncButton.prototype.onjobsucceed = function() {
        var cls;
        cls = this.constructor;
        return this.element.removeClass(cls.LOAD_CLASS).addClass(cls.SUCCEED_CLASS);
      };

      AsyncButton.prototype.onjobfail = function() {
        var cls;
        cls = this.constructor;
        return this.element.removeClass(cls.LOAD_CLASS).addClass(cls.FAIL_CLASS);
      };

      AsyncButton.prototype.onclick = function(e, event) {
        var cls, self;
        self = this;
        cls = this.constructor;
        self.emit(cls.JOB_START_EVENT);
        return AsyncButton.__super__.onclick.apply(this, arguments);
      };

      AsyncButton.prototype._execute = function(errorFn, successFn) {
        throw new exceptions.NotImplementedError();
      };

      /*
          Override this method if async job returns a deferred object
      */


      return AsyncButton;

    })(Button);
    /*
      A button which does a asynchronic job like AJAX request, or WebSQL request when clicked
    
      Usage:
    
        class GetUserButton extends AjaxButton
          this.configure
            url: "/users/1"
            type: "GET"
            dataType: "JSON"
    */

    AjaxButton = (function(_super) {

      __extends(AjaxButton, _super);

      function AjaxButton() {
        return AjaxButton.__super__.constructor.apply(this, arguments);
      }

      AjaxButton.prototype._deferredExecute = function() {
        return $.ajax(this._options);
      };

      return AjaxButton;

    })(AsyncButton);
    return {
      Button: Button,
      AsyncButton: AsyncButton,
      AjaxButton: AjaxButton
    };
  });

}).call(this);
