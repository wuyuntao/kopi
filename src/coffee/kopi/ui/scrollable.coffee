kopi.module("kopi.ui.scrollable")
  .require("kopi.utils.events")
  .require("kopi.utils.css")
  .require("kopi.utils.support")
  .require("kopi.ui.touchable")
  .define (exports, events, css, support, touchable) ->

    class Scrollable extends touchable.Touchable

      kls = this
      kls.TRANSITION_PROPERTY_NAME = css.experimental("transition-property")
      kls.TRANSITION_DURATION_NAME = css.experimental("transition-duration")
      kls.TRANSITION_TIMING_FUNCTION_NAME = css.experimental("transition-timing-function")
      kls.TRANSFORM_ORIGIN_NAME = css.experimental("transform-origin")
      kls.TRANSFORM_NAME = css.experimental("transform")

      kls.TRANSITION_PROPERTY_STYLE = css.experimental("transform")
      # kls.LEGACY_TRANSITION_PROPERTY_STYLE = "top left"
      kls.TRANSITION_DURATION_STYLE = "{ms}ms"
      kls.TRANSITION_TIMING_FUNCTION_NAME = "cubic-bezier(0.33,0.66,0.66,1)"
      kls.TRANSFORM_ORIGIN_STYLE = "0 0"
      kls.TRANSFORM_STYLE = "#{css.TRANSLATE_OPEN}{x}px,{y}px#{css.TRANSLATE_CLOSE}"
      # kls.LEGACY_TRANSFORM_STYLE =
      #   position: absolute
      #   top: "{y}px"
      #   left: "{x}px"

      kls.configure
        # @param  {Integer} start position x
        startX: 0
        # @param  {Integer} start position y
        startY: 0
        scrollX: true
        scrollY: true

      constructor: ->
        super

      onskeleton: ->
        cls = this.constructor
        self = this
        # Set default styles to element
        css = {}
        css[cls.TRANSITION_PROPERTY_NAME] = cls.TRANSITION_PROPERTY_STYLE
        css[cls.TRANSITION_DURATION_NAME] = text.format(cls.TRANSITION_DURATION_STYLE, ms: 0)
        css[cls.TRANSITION_TIMING_FUNCTION_NAME] = cls.TRANSITION_TIMING_FUNCTION_STYLE
        css[cls.TRANSFORM_ORIGIN_NAME] = cls.TRANSFORM_ORIGIN_STYLE
        css[cls.TRANSFORM_NAME] = text.format(cls.TRANSFORM_STYLE, x: 0, y: 0)
        self.element.css css
        super

      ontouchstart: (e, point) ->
        self = this
        self._reset()
        self._startX = self._options.startX
        self._startY = self._options.startY
        self._x = self._options.startX
        self._y = self._options.startY
        self._pointX = point.pageX
        self._pointY = point.pageY
        self._startTime = point.timeStamp or new Date()
        super

      ontouchmove: (e, point) ->
        self = this
        deltaX = point.pageX - self._pointX
        deltaY = point.pageY - self._pointY
        newX = self._x + deltaX
        newY = self._y + deltaY
        timestamp = point.timeStamp or new Date()

        self._pointX = point.pageX
        self._pointY = point.pageY

        # Slow down if outside of the boundaries
        self._moved = true
        self._pos newX, newY

        if timestamp - self._startTime > 300
          self._startTime = timestamp
          self._startX = self._x
          self._startY = self._y

      ontouchend: (e, point) ->
        return if support.touch and point isnt null
        self = this
        momentumX =
          dist: 0
          time: 0
        momentumY =
          dist: 0
          time: 0
        duration = (point.timeStamp or new Date) - self._startTime
        newX = self._x
        newY = self._y

      _reset: ->
        self = this
        self._moved = false
        self._deltaX = 0
        self._deltaY = 0

      _pos: (x, y) ->
        cls = this.constructor
        self = this
        x = if self._options.scrollX then x else 0
        y = if self._options.scrollY then y else 0
        self.element.css cls.TRANSFORM_NAME, text.format(cls.TRANSFORM_STYLE, x: x, y: y)
        self._x = x
        self._y = y

    exports.Scrollable = Scrollable
