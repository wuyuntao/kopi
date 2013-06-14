(function() {
  define("kopi/ui/mixins/togglable", function(require, exports, module) {
    /*
    Add show/hide method to class
    */

    var Togglable;

    Togglable = (function() {
      function Togglable() {}

      Togglable.prototype.show = function() {
        var cls;

        if (!this.hidden) {
          return this;
        }
        cls = this.constructor;
        cls.SHOW_CLASS || (cls.SHOW_CLASS = cls.cssClass("show"));
        this.element.addClass(cls.SHOW_CLASS);
        this.hidden = false;
        return this;
      };

      Togglable.prototype.hide = function() {
        var cls;

        if (this.hidden) {
          return this;
        }
        cls = this.constructor;
        cls.SHOW_CLASS || (cls.SHOW_CLASS = cls.cssClass("show"));
        this.element.removeClass(cls.SHOW_CLASS);
        this.hidden = true;
        return this;
      };

      return Togglable;

    })();
    return {
      Togglable: Togglable
    };
  });

}).call(this);
