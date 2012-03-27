define "kopi/utils/css", (require, exports, module) ->

  $ = require "jquery"
  browser = require "kopi/utils/browser"
  support = require "kopi/utils/support"
  text = require "kopi/utils/text"
  settings = require "kopi/settings"

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
    scaleOpen = "scale3d("
    scaleClose = ",0)"
  else
    translateOpen = "translate("
    translateClose = ")"
    scaleOpen = "scale("
    scaleClose = ")"

  ###
  Generate vender-specified style names
  ###
  experimental = (name) ->
    vendorPrefix + text.dasherize(name)

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

  scale = "#{scaleOpen}{x},{y}#{scaleClose}"
  $.fn.scale = (x=1, y=1) ->
    if support.cssTransform
      this.css transform, text.format(scale, x: x, y: y)
    this

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

  $.fn.toggleDebug = ->
    this.toggleClass("kopi-debug", settings.kopi.debug)

  experimental: experimental
