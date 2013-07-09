(function() {

  define("kopi/utils/css", function(require, exports, module) {
    /*
    # CSS utilities
    
    This module provides some helpers to access CSS3 properties.
    */

    var $, SCALE_CLOSE, SCALE_OPEN, TRANSLATE_CLOSE, TRANSLATE_OPEN, VENDOR_PREFIX, browser, experimental, logger, logging, math, reMatrix, settings, support, text, transform, transitionDuration, transitionTimingFunction;
    $ = require("jquery");
    browser = require("kopi/utils/browser");
    support = require("kopi/utils/support");
    text = require("kopi/utils/text");
    settings = require("kopi/settings");
    logging = require("kopi/logging");
    logger = logging.logger(module.id);
    math = Math;
    VENDOR_PREFIX = browser.webkit ? "-webkit-" : browser.mozilla ? "-moz-" : browser.opera ? "-o-" : browser.msie ? "-ms-" : "";
    if (support.cssTransform3d) {
      TRANSLATE_OPEN = "translate3d(";
      TRANSLATE_CLOSE = ",0)";
      SCALE_OPEN = "scale3d(";
      SCALE_CLOSE = ",0)";
    } else {
      TRANSLATE_OPEN = "translate(";
      TRANSLATE_CLOSE = ")";
      SCALE_OPEN = "scale(";
      SCALE_CLOSE = ")";
    }
    /*
    ## experimental(name)
    
    Return a vendor-prefixed CSS property name.
    
    ```coffeescript
    # return for Chrome: "-webkit-transform"
    # return for Firefox: "-moz-transform"
    # return for Opera: "-o-transform"
    # return for IE: "-ms-transform"
    css.experimental("transform")
    ```
    */

    experimental = function(name) {
      return VENDOR_PREFIX + text.dasherize(name);
    };
    /*
    ## $.fn.duration(duration)
    
    Set duration for CSS3 transition
    */

    transitionDuration = experimental("transition-duration");
    transitionTimingFunction = experimental("transition-timing-function");
    $.fn.duration = function(duration, timingFunction) {
      var el, styles, _i, _len;
      if (duration == null) {
        duration = 0;
      }
      if (timingFunction == null) {
        timingFunction = "ease-out";
      }
      if (!this.length) {
        return this;
      }
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        el = this[_i];
        styles = el.style;
        styles[transitionDuration] = "" + duration + "ms";
        styles[transitionTimingFunction] = timingFunction;
      }
      return this;
    };
    /*
    ## $.fn.translate(x, y)
    
    Move an element along the `x` or `y` axis. Use 3D transform to
    enable hardware acceleration if available.
    */

    transform = experimental("transform");
    $.fn.translate = function(x, y) {
      var el, transformValue, _i, _j, _len, _len1;
      if (x == null) {
        x = 0;
      }
      if (y == null) {
        y = 0;
      }
      if (!this.length) {
        return this;
      }
      if (support.cssTransform) {
        transformValue = "" + TRANSLATE_OPEN + x + "px," + y + "px" + TRANSLATE_CLOSE;
        for (_i = 0, _len = this.length; _i < _len; _i++) {
          el = this[_i];
          el.style[transform] = transformValue;
        }
      } else {
        x = "" + x + "px";
        y = "" + y + "px";
        for (_j = 0, _len1 = this.length; _j < _len1; _j++) {
          el = this[_j];
          el.style.left = x;
          el.style.top = y;
        }
      }
      return this;
    };
    /*
    ## $.fn.scale(x, y)
    
    Scale an element along the `x` and `y` axis. Use 3D transform to
    enable hardware acceleration if available.
    */

    $.fn.scale = function(x, y) {
      var el, transformValue, _i, _len;
      if (x == null) {
        x = 1;
      }
      if (y == null) {
        y = 1;
      }
      if (!this.length) {
        return this;
      }
      if (support.cssTransform) {
        transformValue = "" + SCALE_OPEN + x + "," + y + SCALE_CLOSE;
        for (_i = 0, _len = this.length; _i < _len; _i++) {
          el = this[_i];
          el.style[transform] = transformValue;
        }
      }
      return this;
    };
    /*
    ## $.fn.transform(scaleX, scaleY, offsetX, offsetY)
    
    Move and scale an element along the `x` and `y` axis. Use 3D transform to
    enable hardware acceleration if available.
    */

    $.fn.transform = function(scaleX, scaleY, offsetX, offsetY) {
      var el, transformValue, _i, _len;
      if (scaleX == null) {
        scaleX = 1;
      }
      if (scaleY == null) {
        scaleY = 1;
      }
      if (offsetX == null) {
        offsetX = 0;
      }
      if (offsetY == null) {
        offsetY = 0;
      }
      if (!(this.length && support.cssTransform)) {
        return this;
      }
      transformValue = "" + SCALE_OPEN + scaleX + "," + scaleY + SCALE_CLOSE + " ";
      transformValue += "" + TRANSLATE_OPEN + (math.round(offsetX)) + "px," + (math.round(offsetY)) + "px" + TRANSLATE_CLOSE;
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        el = this[_i];
        el.style[transform] = transformValue;
      }
      return this;
    };
    /*
    ## $.fn.parseMatrix()
    
    Parse CSS Matrix from the element
    */

    reMatrix = /[^0-9-.,]/g;
    $.fn.parseMatrix = function() {
      var matrix;
      if (!support.cssMatrix) {
        return;
      }
      matrix = this.css(transform).replace(reMatrix, "").split(",");
      if (matrix.length >= 6) {
        return {
          x: parseInt(matrix[4]),
          y: parseInt(matrix[5])
        };
      }
    };
    /*
    ## $.fn.toggleDebug()
    
    Add or remove `kopi-debug` class for element based on configuration.
    */

    $.fn.toggleDebug = function() {
      return this.toggleClass("kopi-debug", settings.kopi.debug);
    };
    return {
      experimental: experimental
    };
  });

}).call(this);
