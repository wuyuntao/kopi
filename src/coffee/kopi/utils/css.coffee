kopi.module("kopi.utils.css")
  .require("kopi.utils.browser")
  .require("kopi.utils.text")
  .define (exports, browser, text) ->

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

    ###
    Generate vender-specified style names
    ###
    experimental = (name) ->
      VENDOR_PREFIX + text.underscore(name)

    exports.experimental = experimental
