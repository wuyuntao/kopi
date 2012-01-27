kopi.module("kopi.utils.browser")
  .require("kopi.utils.object")
  .define (exports, object) ->

    nav = navigator
    av = nav.appVersion
    ua = nav.userAgent
    all = ["webkit", "opera", "msie", "mozilla", "android", "iphone", "ipad"]

    exports.all = all
    object.extend exports, $.browser,
      android:  (/android/gi).test(av)
      iphone:   (/ipod|iphone/gi).test(av)
      ipad:     (/ipad/gi).test(av)
