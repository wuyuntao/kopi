kopi.module("kopi.utils.browser")
  .require("kopi.utils.object")
  .define (exports, object) ->

    nav = navigator
    av = nav.appVersion
    ua = nav.userAgent

    object.extend exports, $.browser,
      android:  (/android/gi).test(av)
      iphone:   (/ipod|iphone/gi).test(av)
      ipad:     (/ipad/gi).test(av)
      idevice:  (/ipod|iphone|ipad/gi).test(av)
