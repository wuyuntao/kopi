(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/ui/switchers", function(require, exports, module) {
    var CURRENT, HIDE, SHOW, Switcher, array, exceptions, groups, klass, logger, logging;
    exceptions = require("kopi/exceptions");
    logging = require("kopi/logging");
    array = require("kopi/utils/array");
    klass = require("kopi/utils/klass");
    groups = require("kopi/ui/groups");
    logger = logging.logger(module.id);
    HIDE = "hide";
    SHOW = "show";
    CURRENT = "current";
    Switcher = (function(_super) {

      __extends(Switcher, _super);

      Switcher.widgetName("Switcher");

      function Switcher() {
        Switcher.__super__.constructor.apply(this, arguments);
        this._currentKey = null;
      }

      Switcher.prototype.removeAt = function(index) {
        if (index === this._currentChildIndex) {
          throw new exceptions.ValueError("Can not remove current view.");
        }
        return Switcher.__super__.removeAt.call(this, index);
      };

      /*
      Return currently displayed child.
      */


      Switcher.prototype.current = function() {
        return this._children[this.currentAt()];
      };

      /*
      Return index of currently displayed child
      */


      Switcher.prototype.currentAt = function() {
        return array.indexOf(this._keys, this._currentKey);
      };

      /*
      Manually show the next child.
      */


      Switcher.prototype.showNext = function() {
        var index;
        index = this.currentAt();
        if ((index != null) && index + 1 < this._keys.length) {
          this.showAt(index + 1);
        }
        return this;
      };

      /*
      Manually show the previous child.
      */


      Switcher.prototype.showPrevious = function() {
        var index;
        index = this.currentAt();
        if ((index != null) && index >= 1) {
          this.showAt(index - 1);
        }
        return this;
      };

      /*
      Manually show the child at the specified position in the group.
      */


      Switcher.prototype.showAt = function(index, options) {
        var child, currentAt, self;
        self = this;
        if (!((0 <= index && index < self._children.length))) {
          throw new exceptions.ValueError("Invalid index of child " + index + " of " + self._children.length);
        }
        currentAt = self.currentAt();
        if (currentAt && currentAt === index) {
          logger.warn("Child is already active.");
          return self;
        }
        if (self.locked) {
          return self;
        }
        child = self._children[index];
        return self._switch(self._children[currentAt], child, options);
      };

      /*
      Manually show the child
      */


      Switcher.prototype.show = function(child, options) {
        return this.showAt(this.indexOf(child), options);
      };

      Switcher.prototype._switch = function(fromChild, toChild, options) {
        var doneFn, hidden, hideFn, self, showFn, shown;
        self = this;
        self.lock();
        if (!fromChild) {
          self._show(toChild);
          return self;
        }
        hidden = false;
        shown = false;
        doneFn = function() {
          if (hidden && shown) {
            self._currentKey = self._key(toChild);
            return self.unlock();
          }
        };
        hideFn = function(error) {
          hidden = true;
          return doneFn();
        };
        showFn = function(error) {
          shown = true;
          return doneFn();
        };
        return self._hide(fromChild, hideFn)._show(toChild, showFn);
      };

      /*
      Show the child.
      */


      Switcher.prototype._show = function(child, fn) {
        var cls;
        cls = this._options.childClass;
        child.element.addClass("" + (cls.cssClass(SHOW)) + " " + (cls.cssClass(CURRENT)));
        this._currentKey = this._key(child);
        if (fn) {
          fn(null);
        }
        return this;
      };

      /*
      Hide the child.
      */


      Switcher.prototype._hide = function(child, fn) {
        var cls;
        cls = this._options.childClass;
        child.element.removeClass("" + (cls.cssClass(SHOW)) + " " + (cls.cssClass(CURRENT)));
        if (fn) {
          fn(null);
        }
        return this;
      };

      return Switcher;

    })(groups.Group);
    return {
      Switcher: Switcher
    };
  });

}).call(this);
