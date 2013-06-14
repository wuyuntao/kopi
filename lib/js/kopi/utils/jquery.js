(function() {
  define("kopi/utils/jquery", function(require, exports, module) {
    var $, bridge, doc, html;

    $ = require("jquery");
    html = require("kopi/utils/html");
    doc = document;
    $.fn.itemprop = function() {
      if (!this.length) {
        return void 0;
      }
      return html.prop(this);
    };
    $.fn.itemscope = function() {
      if (!this.length) {
        return {};
      }
      return html.scope(this);
    };
    $.fn.replaceClass = function(regexp, replacement) {
      if (!this.length) {
        return this;
      }
      html.replaceClass(this, regexp, replacement);
      return this;
    };
    $.fn.tag = function() {
      if (this.length) {
        return this[0].tagName;
      } else {
        return null;
      }
    };
    /*
    Convert widget class to a jQUery-UI-style plugin
    */

    return bridge = function(widget) {};
  });

}).call(this);
