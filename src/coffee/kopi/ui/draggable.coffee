kopi.module("kopi.ui.draggable")
  .require("kopi.logging")
  .require("kopi.utils.css")
  .require("kopi.utils.events")
  .require("kopi.utils.text")
  .require("kopi.ui.touchable")
  .define (exports, logging, css, events, text, touchable) ->

    math = Math
    logger = logging.logger(exports.name)

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

      kls.configure
        momentum: true
        deceleration: 0.0006

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
        self._x or= self._options.startX
        self._y or= self._options.startY
        self._startX = self._x
        self._startY = self._y
        point = self._points(event)
        self._pointX = point.pageX
        self._pointY = point.pageY
        self._timeStamp = self._startTime = point.timeStamp or new Date().getTime()
        self._duration(0)

        # if self._options.momentum
        #   matrix = this.element.css(TRANSFORM).replace(RE_MATRIX, "").split(",")
        #   x = parseInt(matrix[4])
        #   y = parseInt(matrix[5])
        #   if x != self._x or y != self._y
        #     self.element.unbind(events.WEBKIT_TRANSITION_END_EVENT)
        #     self._steps = []
        #     self._position(x, y)
        super

      ontouchmove: (e, event) ->
        event.preventDefault()
        event.stopPropagation()

        self = this
        options = self._options
        point = self._points(event)
        deltaX = point.pageX - self._pointX
        deltaY = point.pageY - self._pointY
        self._deltaX += deltaX
        self._deltaY += deltaY
        newX = self._x + deltaX
        newY = self._y + deltaY
        timeStamp = point.timeStamp or new Date().getTime()
        duration = timeStamp - self._timeStamp
        self._timeStamp = timeStamp
        logger.debug("x: #{self._deltaX}, y: #{self._deltaY}, duration: #{duration}")

        self._pointX = point.pageX
        self._pointY = point.pageY

        self._moved = true
        self._duration(duration) if duration > 100
        self._position(self._deltaX, self._deltaY)

        # if timestamp - self._startTime > 300
        #   self._startTime = timestamp
        #   self._startX = self._x
        #   self._startY = self._y
        super

      ontouchend: (e, event) ->
        self = this
        # point = self._points(event)
        # return if support.touch and point isnt null
        # momentumX =
        #   dist: 0
        #   time: 0
        # momentumY =
        #   dist: 0
        #   time: 0
        # duration = (point.timeStamp or new Date().getTime()) - self._startTime
        # newX = self._x
        # newY = self._y

        # if not self._moved
        #   # TODO Find last touched element and trigger click event for it
        #   return

        # event.preventDefault()
        # event.stopPropagation()

        # if duration < 300 and self._options.momentum
        #   momentumX = if not newX then momentumX else
        #     self._momentum(newX - self._startX, duration, -self._x
        #       , self._scrollerWidth - self._elementWidth + self._x
        #       , if self._options.bounce then self._elementWidth else 0)
        #   momentumY = if not newY then momentumY else
        #     self._momentum(newY - self._startY, duration, -self._y
        #       , self._scrollerHeight - self._elementHeight + self._y
        #       , if self._options.bounce then self._elementHeight else 0)

        #   newX = self._x + momentumX.dist
        #   newY = self._y + momentumY.dist

        #   if (self._x > self._minScrollX and newX > self._minScrollX) or (self.x < self._maxScrollX and newX < self._maxScrollX)
        #     momentumX =
        #       dist: 0
        #       time: 0
        #   if (self._y > self._minScrollY and newY > self._minScrollY) or (self._y < self._maxScrollY and newY < self._maxScrollY)
        #     momentumY =
        #       dist: 0
        #       time: 0

        # if momentumX.dist or momentumY.dist
        #   duration = math.max(momentumX.time, momentumY.time, 10)
        #   self.scrollTo(math.round(newX), math.round(newY), duration)
        #   return

        # self._resetPosition(200)
        super

      ontouchcancel: (e, event) ->
        this.ontouchend(arguments...)
        super

      _position: (x, y) ->
        cls = this.constructor
        self = this
        logger.debug("x: #{x}, y: #{y}")
        # x = if self._options.dragX then x else 0
        # y = if self._options.dragY then y else 0
        self.element.css TRANSFORM, text.format(cls.TRANSFORM_STYLE, x: x, y: y)
        self._x = x
        self._y = y
        self

      # Set transition duration for scroller
      _duration: (duration) ->
        this.element.css TRANSITION_DURATION, duration + 'ms'
        this

    exports.Draggable = Draggable
