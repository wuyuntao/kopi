kopi.module("kopi.utils.css")
  .require("kopi.utils.browser")
  .require("kopi.utils.support")
  .require("kopi.utils.text")
  .define (exports, browser, support, text) ->

    VENDOR_PREFIX = if browser.webkit
      "-webkit-"
    else if browser.firefox
      "-moz-"
    else if browser.opera
      "-o-"
    else if browser.msie
      "-ms-"
    else
      ""

    if support.cssMatrix
      TRANSLATE_OPEN = "translate3d("
      TRANSLATE_CLOSE = ",0)"
    else
      TRANSLATE_OPEN = "translate("
      TRANSLATE_CLOSE = ")"

    ###
    Generate vender-specified style names
    ###
    experimental = (name) ->
      VENDOR_PREFIX + text.underscore(name, '-')

    exports.experimental = experimental
    exports.TRANSLATE_OPEN = TRANSLATE_OPEN
    exports.TRANSLATE_CLOSE = TRANSLATE_CLOSE
