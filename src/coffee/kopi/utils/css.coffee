kopi.module("kopi.utils.css")
  .require("kopi.utils.browser")
  .require("kopi.utils.support")
  .require("kopi.utils.text")
  .define (exports, browser, support, text) ->

    vendorPrefix = if browser.webkit
      "-webkit-"
    else if browser.mozilla
      "-moz-"
    else if browser.opera
      "-o-"
    else if browser.msie
      "-ms-"
    else
      ""

    if support.cssTransform3d
      translateOpen = "translate3d("
      translateClose = ",0)"
    else
      translateOpen = "translate("
      translateClose = ")"

    ###
    Generate vender-specified style names
    ###
    experimental = (name) ->
      vendorPrefix + text.underscore(name, '-')

    ###
    Some extra jQuery utilities for CSS-related properties

    Set duration for CSS3 transition
    ###
    transitionDuration = experimental("transition-duration")
    $.fn.duration = (duration=0) ->
      this.css(transitionDuration, duration + "ms")

    ###
    Set translate
    ###
    translate = "#{translateOpen}{x}px,{y}px#{translateClose}"
    transform = experimental("transform")
    $.fn.translate = (x=0, y=0) ->
      if support.cssTransform
        this.css transform, text.format(translate, x: x, y: y)
      else
        this.css left: x, top: y

    ###
    Parse css Matrix from element
    ###
    reMatrix = /[^0-9-.,]/g
    $.fn.parseMatrix = ->
      # TODO What if browser does not support transform matrix?
      matrix = this.css(transform).replace(reMatrix, "").split(",")
      if matrix.length >= 6
        x: parseInt(matrix[4])
        y: parseInt(matrix[5])

    exports.experimental = experimental
