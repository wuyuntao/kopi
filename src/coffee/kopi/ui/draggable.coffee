define "kopi/ui/draggable", (require, exports, module) ->

  logging = require "kopi/logging"
  css = require "kopi/utils/css"
  events = require "kopi/utils/events"
  text = require "kopi/utils/text"
  touchable = require "kopi/ui/touchable"

  math = Math
  logger = logging.logger(module.id)

  TRANSITION_PROPERTY = css.experimental("transition-property")
  TRANSITION_DURATION = css.experimental("transition-duration")
  TRANSITION_TIMING_FUNCTION = css.experimental("transition-timing-function")
  TRANSFORM_ORIGIN = css.experimental("transform-origin")
  TRANSFORM = css.experimental("transform")

  RE_MATRIX = /[^0-9-.,]/g

  ###
  A widget can be dragged by mouse or finger

  ###
  class Draggable extends touchable.Touchable

    kls = this
    kls.RESIZE_EVENT = "resize"
    kls.TRANSITION_END_EVENT = "transitionend"
    kls.TRANSITION_PROPERTY_STYLE = css.experimental("transform")
    # kls.LEGACY_TRANSITION_PROPERTY_STYLE = "top left"
    kls.TRANSITION_DURATION_STYLE = "0ms"
    kls.TRANSITION_TIMING_FUNCTION_STYLE = "cubic-bezier(0.33,0.66,0.66,1)"
    kls.TRANSFORM_ORIGIN_STYLE = "0 0"
    kls.TRANSFORM_STYLE = "#{css.TRANSLATE_OPEN}{x}px,{y}px#{css.TRANSLATE_CLOSE}"

    moveTo: (x, y, duration) ->
      self = this
      self._stopAnimation()
      step =
        x: x
        y: y
        duration: duration or 0
      self._steps.push(step)
      self._animate()

    onskeleton: ->
      cls = this.constructor
      self = this
      # TODO Move following code to some private/helper method
      styles = {}
      styles[TRANSITION_PROPERTY] = cls.TRANSITION_PROPERTY_STYLE
      styles[TRANSITION_DURATION] = cls.TRANSITION_DURATION_STYLE
      styles[TRANSITION_TIMING_FUNCTION] = cls.TRANSITION_TIMING_FUNCTION_STYLE
      styles[TRANSFORM_ORIGIN] = cls.TRANSFORM_ORIGIN_STYLE
      styles[TRANSFORM] = text.format(cls.TRANSFORM_STYLE, x: 0, y: 0)
      self.element.css(styles)
      super

    ontouchstart: (e, event) ->
      cls = this.constructor
      self = this
      self._moved = false
      self._animating = false
      self._deltaX or= 0
      self._deltaY or= 0
      point = self._points(event)
      self._pointX = point.pageX
      self._pointY = point.pageY
      self._timeStamp = self._startTime = point.timeStamp or new Date().getTime()
      self._duration(0)
      super

    ontouchmove: (e, event) ->
      event.preventDefault()
      event.stopPropagation()

      self = this
      options = self._options
      point = self._points(event)
      self._deltaX += point.pageX - self._pointX
      self._deltaY += point.pageY - self._pointY
      self._pointX = point.pageX
      self._pointY = point.pageY

      self._moved = true
      self._position(self._deltaX, self._deltaY)
      logger.debug("x: #{self._deltaX}, y: #{self._deltaY}")

      timestamp = point.timeStamp or new Date().getTime()
      if timestamp - self._startTime > 300
        self._startTime = timestamp
      super

    ontouchend: (e, event) ->
      self = this
      point = self._points(event)
      if not self._moved
        return
      event.preventDefault()
      event.stopPropagation()
      super

    ontouchcancel: (e, event) ->
      this.ontouchend(arguments...)
      super

    _resetPosition: (duration) ->
      self = this
      self.moveTo(self._deltaX, self._deltaY, duration)

    _position: (x, y) ->
      cls = this.constructor
      self = this
      self.element.css TRANSFORM, text.format(cls.TRANSFORM_STYLE, x: x, y: y)
      self._x = x
      self._y = y
      self

    # Set transition duration for scroller
    _duration: (duration) ->
      this.element.css TRANSITION_DURATION, duration + 'ms'
      this

    _stopAnimation: ->
      this._steps = []
      this._moved = false
      this._animating = false
      this

    _animate: ->
      cls = this.constructor
      self = this
      return if self._animating
      if not self._steps.length
        self._resetPosition(400)
        return self

      startTime = new Date().getTime()
      step = self._steps.shift()
      self._animating = true
      self._moved = true
      self._duration(step.duration)._position(step.x, step.y)
      self._animating = false
      if step.duration
        transitionEndFn = (e) ->
          e.preventDefault()
          e.stopPropagation()
          self.emit cls.TRANSITION_END_EVENT
        self.element.bind events.WEBKIT_TRANSITION_END_EVENT, transitionEndFn
      else
        self._resetPosition(0)
      return self

  Draggable: Draggable
