(function() {

  define("kopi/utils/browser", function(require, exports, module) {
    var $, all, av, nav, object, ua;
    $ = require("jquery");
    object = require("kopi/utils/object");
    nav = navigator;
    av = nav.appVersion.toLowerCase();
    ua = nav.userAgent.toLowerCase();
    all = ["webkit", "opera", "msie", "mozilla", "android", "iphone", "ipad"];
    object.extend(module.exports, $.browser, {
      webkit: /webkit/.test(ua),
      opera: /opera/.test(ua),
      msie: /msie/.test(ua),
      mozilla: (ua.indexOf("compatible") < 0) && /mozilla/.test(ua),
      android: /android/.test(av),
      iphone: /ipod|iphone/.test(av),
      ipad: /ipad/.test(av),
      all: all
    });
  });

}).call(this);
