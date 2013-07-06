define "kopi/utils/css", (require, exports, module) ->

  ###
  # CSS utilities

  This module provides some helpers to access CSS3 properties.

  ###
  $ = require "jquery"
  browser = require "kopi/utils/browser"
  support = require "kopi/utils/support"
  text = require "kopi/utils/text"
  settings = require "kopi/settings"
  logging = require "kopi/logging"

  logger = logging.logger(module.id)
  math = Math

  VENDOR_PREFIX = if browser.webkit
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
    TRANSLATE_OPEN = "translate3d("
    TRANSLATE_CLOSE = ",0)"
    SCALE_OPEN = "scale3d("
    SCALE_CLOSE = ",0)"
  else
    TRANSLATE_OPEN = "translate("
    TRANSLATE_CLOSE = ")"
    SCALE_OPEN = "scale("
    SCALE_CLOSE = ")"

  ###
  ## experimental(name)

  Return a vendor-prefixed CSS property name.

  ```coffeescript
  # return for Chrome: "-webkit-transform"
  # return for Firefox: "-moz-transform"
  # return for Opera: "-o-transform"
  # return for IE: "-ms-transform"
  css.experimental("transform")
  ```

  ###
  experimental = (name) ->
    VENDOR_PREFIX + text.dasherize(name)

  ###
  ## $.fn.duration(duration)

  Set duration for CSS3 transition
  ###
  transitionDuration = experimental("transition-duration")
  transitionTimingFunction = experimental("transition-timing-function")
  $.fn.duration = (duration=0, timingFunction="ease-out") ->
    return this unless this.length
    for el in this
      styles = el.style
      styles[transitionDuration] = "#{duration}ms"
      styles[transitionTimingFunction] = timingFunction
    this

  ###
  ## $.fn.translate(x, y)

  Move an element along the `x` or `y` axis. Use 3D transform to
  enable hardware acceleration if available.

  ###
  transform = experimental("transform")
  $.fn.translate = (x=0, y=0) ->
    return this unless this.length
    if support.cssTransform
      transformValue = "#{TRANSLATE_OPEN}#{x}px,#{y}px#{TRANSLATE_CLOSE}"
      for el in this
        el.style[transform] = transformValue
    else
      x = "#{x}px"
      y = "#{y}px"
      for el in this
        el.style.left = x
        el.style.top = y
    this

  ###
  ## $.fn.scale(x, y)

  Scale an element along the `x` and `y` axis. Use 3D transform to
  enable hardware acceleration if available.

  ###
  $.fn.scale = (x=1, y=1) ->
    return this unless this.length
    if support.cssTransform
      transformValue = "#{SCALE_OPEN}#{x},#{y}#{SCALE_CLOSE}"
      for el in this
        el.style[transform] = transformValue
    this

  ###
  ## $.fn.transform(scaleX, scaleY, offsetX, offsetY)

  Move and scale an element along the `x` and `y` axis. Use 3D transform to
  enable hardware acceleration if available.

  ###
  $.fn.transform = (scaleX=1, scaleY=1, offsetX=0, offsetY=0) ->
    return this unless this.length and support.cssTransform
    transformValue = "#{SCALE_OPEN}#{scaleX},#{scaleY}#{SCALE_CLOSE} "
    transformValue += "#{TRANSLATE_OPEN}#{math.round(offsetX)}px,#{math.round(offsetY)}px#{TRANSLATE_CLOSE}"
    for el in this
      el.style[transform] = transformValue
    this

  ###
  ## $.fn.parseMatrix()

  Parse CSS Matrix from the element
  ###
  reMatrix = /[^0-9-.,]/g
  $.fn.parseMatrix = ->
    return unless support.cssMatrix
    matrix = this.css(transform).replace(reMatrix, "").split(",")
    if matrix.length >= 6
      x: parseInt(matrix[4])
      y: parseInt(matrix[5])

  ###
  ## $.fn.toggleDebug()

  Add or remove `kopi-debug` class for element based on configuration.
  ###
  $.fn.toggleDebug = ->
    this.toggleClass("kopi-debug", settings.kopi.debug)

  ## Exports
  experimental: experimental
