(function() {
  define("kopi/utils/css", function(require, exports, module) {
    /*
    # CSS utilities
    
    This module provides some helpers to access CSS3 properties.
    */

    var $, SCALE_CLOSE, SCALE_OPEN, TRANSLATE_CLOSE, TRANSLATE_OPEN, VENDOR_PREFIX, browser, experimental, reMatrix, settings, support, text, transform, transitionDuration;

    $ = require("jquery");
    browser = require("kopi/utils/browser");
    support = require("kopi/utils/support");
    text = require("kopi/utils/text");
    settings = require("kopi/settings");
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
    $.fn.duration = function(duration) {
      if (duration == null) {
        duration = 0;
      }
      return this.css(transitionDuration, duration + "ms");
    };
    /*
    ## $.fn.translate(x, y)
    
    Move an element along the `x` or `y` axis. Use 3D transform to
    enable hardware acceleration if available.
    */

    transform = experimental("transform");
    $.fn.translate = function(x, y) {
      if (x == null) {
        x = 0;
      }
      if (y == null) {
        y = 0;
      }
      if (support.cssTransform) {
        return this.css(transform, "" + TRANSLATE_OPEN + x + "px," + y + "px" + TRANSLATE_CLOSE);
      } else {
        return this.css({
          left: x,
          top: y
        });
      }
    };
    /*
    ## $.fn.scale(x, y)
    
    Scale an element along the `x` and `y` axis. Use 3D transform to
    enable hardware acceleration if available.
    */

    $.fn.scale = function(x, y) {
      if (x == null) {
        x = 1;
      }
      if (y == null) {
        y = 1;
      }
      if (support.cssTransform) {
        this.css(transform, "" + SCALE_OPEN + x + "," + y + SCALE_CLOSE);
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
