define "kopi/utils/browser", (require, exports, module) ->

  $ = require "jquery"
  object = require "kopi/utils/object"

  nav = navigator
  av = nav.appVersion
  ua = nav.userAgent
  all = ["webkit", "opera", "msie", "mozilla", "android", "iphone", "ipad"]

  all: all
  object.extend exports, $.browser,
    android:  (/android/gi).test(av)
    iphone:   (/ipod|iphone/gi).test(av)
    ipad:     (/ipad/gi).test(av)
