define "kopi/utils/browser", (require, exports, module) ->

  $ = require "jquery"
  object = require "kopi/utils/object"

  nav = navigator
  av = nav.appVersion.toLowerCase()
  ua = nav.userAgent.toLowerCase()
  all = ["webkit", "opera", "msie", "mozilla", "android", "iphone", "ipad"]

  # Extend `jQuery.browser` with some mobile browsers, like Android and iOS
  #
  # NOTE
  # Since jQuery removed $.browser from version 1.9, we have to do it by
  # ourselves
  # -- Wu Yuntao, 2013-07-06
  object.extend module.exports, $.browser,
    webkit: (/webkit/).test(ua)
    opera: (/opera/).test(ua)
    msie: (/msie/).test(ua)
    mozilla: (ua.indexOf("compatible") < 0) and /mozilla/.test(ua)
    android: (/android/).test(av)
    iphone: (/ipod|iphone/).test(av)
    ipad: (/ipad/).test(av)
    all: all
  return
