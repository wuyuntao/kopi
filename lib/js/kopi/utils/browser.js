(function() {
  define("kopi/utils/browser", function(require, exports, module) {
    var $, all, av, nav, object, ua;

    $ = require("jquery");
    object = require("kopi/utils/object");
    nav = navigator;
    av = nav.appVersion;
    ua = nav.userAgent;
    all = ["webkit", "opera", "msie", "mozilla", "android", "iphone", "ipad"];
    return object.extend(exports, $.browser, {
      android: /android/gi.test(av),
      iphone: /ipod|iphone/gi.test(av),
      ipad: /ipad/gi.test(av),
      all: all
    });
  });

}).call(this);
