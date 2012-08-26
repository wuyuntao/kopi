define "kopi/utils/browser", (require, exports, module) ->

  $ = require "jquery"
  object = require "kopi/utils/object"

  nav = navigator
  av = nav.appVersion
  ua = nav.userAgent
  all = ["webkit", "opera", "msie", "mozilla", "android", "iphone", "ipad"]

  # Extend `jQuery.browser` with some mobile browsers, like Android and iOS
  #
  # DEPRECATED Will be removed if jQuery removes `jQuery.browser` in future.
  object.extend exports, $.browser,
    android: (/android/gi).test(av)
    iphone: (/ipod|iphone/gi).test(av)
    ipad: (/ipad/gi).test(av)
    all: all
