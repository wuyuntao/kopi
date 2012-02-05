kopi.module("kopi.ui.scrollable")
  .require("kopi.exceptions")
  .require("kopi.logging")
  .require("kopi.utils.events")
  .require("kopi.utils.css")
  .require("kopi.utils.klass")
  .require("kopi.utils.support")
  .require("kopi.utils.text")
  .require("kopi.utils.number")
  .require("kopi.ui.touchable")
  .define (exports, exceptions, logging, events
                  , css, klass, support, text, number, touchable) ->

    math = Math
    logger = logging.logger(exports.name)

    TRANSITION_PROPERTY = css.experimental("transition-property")
    TRANSITION_TIMING_FUNCTION = css.experimental("transition-timing-function")
    TRANSFORM_ORIGIN = css.experimental("transform-origin")
    TRANSFORM = css.experimental("transform")

    RE_MATRIX = /[^0-9-.,]/g

    ###
    TODO Support legacy animation

    ###
    class Scrollable extends touchable.Touchable

      kls = this
      kls.RESIZE_EVENT = "resize"
      kls.TRANSITION_END_EVENT = "transitionend"

      kls.TRANSITION_PROPERTY_STYLE = css.experimental("transform")
      # kls.LEGACY_TRANSITION_PROPERTY_STYLE = "top left"
      kls.TRANSITION_TIMING_FUNCTION_STYLE = "cubic-bezier(0.33,0.66,0.66,1)"
      kls.TRANSFORM_ORIGIN_STYLE = "0 0"
      kls.EVENT_NAMESPACE = "scrollable"
      # kls.LEGACY_TRANSFORM_STYLE =
      #   position: absolute
      #   top: "{y}px"
      #   left: "{x}px"

      kls.configure
        # @param  {Integer} start position x
        startX: 0
        # @param  {Integer} start position y
        startY: 0
        originX: 0
        originY: 0
        scrollX: true
        scrollY: true
        bounce: true
        momentum: true
        damping: 0.5
        deceleration: 0.0006
        ontransitionend: null
        onresize: null
        snap: false
        snapThreshold: 1

      klass.accessor kls.prototype, "scroller"

      constructor: ->
        super
        self = this
        options = self._options
        self._originX = options.originX
        self._originY = options.originY
        self._x = options.startX
        self._y = options.startY

      scrollTo: (x, y, duration) ->
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
        # self.element.css('overflow', 'hidden')

        self._scroller = self._ensureScroller()
        # Set default styles to element
        styles = {}
        styles[TRANSITION_PROPERTY] = cls.TRANSITION_PROPERTY_STYLE
        styles[TRANSITION_TIMING_FUNCTION] = cls.TRANSITION_TIMING_FUNCTION_STYLE
        styles[TRANSFORM_ORIGIN] = cls.TRANSFORM_ORIGIN_STYLE
        self._scroller
          .css(styles)
          .duration(0)
          .translate(0, 0)
        super

      onrender: ->
        self = this
        cls = this.constructor
        self.emit(cls.RESIZE_EVENT)
        super

      ontouchstart: (e, event) ->
        cls = this.constructor
        self = this
        options = self._options
        self._moved = false
        self._animating = false
        # Needed by snap threshold
        self._absStartX = self._startX = self._x
        self._absStartY = self._startY = self._y
        point = self._points(event)
        self._pointX = point.pageX
        self._pointY = point.pageY
        self._startTime = point.timeStamp or new Date().getTime()
        self._directionX = 0
        self._directionY = 0
        self._duration(0)

        if self._options.momentum
          matrix = self._scroller.parseMatrix()
          if matrix.x != self._x or matrix.y != self._y
            self._scroller.unbind(events.WEBKIT_TRANSITION_END_EVENT)
            self._steps = []
            self._position(matrix.x, matrix.y)
        super

      ontouchmove: (e, event) ->
        event.preventDefault()
        event.stopPropagation()

        self = this
        options = self._options
        point = self._points(event)
        deltaX = point.pageX - self._pointX
        deltaY = point.pageY - self._pointY
        newX = self._x + deltaX
        newY = self._y + deltaY
        self._pointX = point.pageX
        self._pointY = point.pageY
        timestamp = point.timeStamp or new Date().getTime()
        self._directionX = if deltaX == 0 then 0 else -deltaX / math.abs(deltaX)
        self._directionY = if deltaY == 0 then 0 else -deltaY / math.abs(deltaY)

        # Slow down If outside of the boundaries
        if self._minScrollX < newX or newX < self._maxScrollX
          newX = if options.bounce
              self._x + deltaX * options.damping
            else if newX >= self._minScrollX and self._maxScrollX >= self._maxScrollX
              self._minScrollX
            else
              self._maxScrollX

        if self._minScrollY < newY or newY < self._maxScrollY
          newY = if options.bounce
              self._y + deltaY * options.damping
            else if newY >= self._minScrollY and self._maxScrollY >= self._minScrollY
              self._minScrollY
            else
              self._maxScrollY

        self._moved = true
        self._position(newX, newY)

        # Reset start time and position if mouse or finger stops for a while
        if timestamp - self._startTime > 300
          self._startTime = timestamp
          self._startX = self._x
          self._startY = self._y
        super

      ontouchend: (e, event) ->
        self = this
        point = self._points(event)
        return if support.touch and point isnt null

        options = self._options
        momentumX =
          dist: 0
          time: 0
        momentumY =
          dist: 0
          time: 0
        duration = (point.timeStamp or new Date().getTime()) - self._startTime
        newX = self._x
        newY = self._y

        if not self._moved
          # TODO Find last touched element and trigger click event for it
          return

        event.preventDefault()
        event.stopPropagation()

        if duration < 300 and options.momentum
          momentumX = if not newX then momentumX else
            self._momentum(newX - self._startX
              , duration
              , -self._x
              , self._scrollerWidth - self._elementWidth + self._x
              , if options.bounce then self._elementWidth else 0)
          momentumY = if not newY then momentumY else
            self._momentum(newY - self._startY
              , duration
              , -self._y
              , self._scrollerHeight - self._elementHeight + self._y
              , if options.bounce then self._elementHeight else 0)

          newX = self._x + momentumX.dist
          newY = self._y + momentumY.dist

          if (self._x > self._minScrollX and newX > self._minScrollX) or (self.x < self._maxScrollX and newX < self._maxScrollX)
            momentumX =
              dist: 0
              time: 0
          if (self._y > self._minScrollY and newY > self._minScrollY) or (self._y < self._maxScrollY and newY < self._maxScrollY)
            momentumY =
              dist: 0
              time: 0

        super

        if momentumX.dist or momentumY.dist
          newDuration = math.max(momentumX.time, momentumY.time, 10)
          if options.snap
            self._snapPosition(newX, newY, duration)
            return

          self.scrollTo(math.round(newX), math.round(newY), newDuration)
          return

        if options.snap
          self._snapPosition(newX, newY, duration, true)
          return

        self._resetPosition(200)

      ontouchcancel: ->
        this.ontouchend(arguments...)
        super

      ontransitionend: (e, event) ->
        cls = this.constructor
        self = this
        self._scroller.unbind(events.WEBKIT_TRANSITION_END_EVENT)
        self._animate()
        self._callback(cls.TRANSITION_END_EVENT, arguments)

      onresize: ->
        cls = this.constructor
        self = this
        self._elementWidth = self.element.innerWidth()
        self._elementHeight = self.element.innerHeight()
        elementOffset = self.element.offset()
        self._elementOffsetLeft = -elementOffset.left
        self._elementOffsetTop = -elementOffset.top

        self._size()

        self._scrollerWidth = math.max(self._scroller.outerWidth(), self._elementWidth)
        self._scrollerHeight = math.max(self._scroller.outerHeight(), self._elementHeight)

        self._minScrollX = 0
        self._minScrollY = 0
        self._maxScrollX = self._elementWidth - self._scrollerWidth
        self._maxScrollY = self._elementHeight - self._scrollerHeight

        self._scrollX = self._options.scrollX and self._maxScrollX < self._minScrollX
        self._scrollY = self._options.scrollY and self._maxScrollY < self._minScrollY

        self._directionX = 0
        self._directionY = 0

        self._duration(0)
        self._callback(cls.RESIZE_EVENT, arguments)

      ###
      Calculate width and height of scroller
      ###
      _size: ->
        self = this
        children = self._scroller.children()
        if children.length > 0

          # Set total width
          if self._options.scrollX
            scrollerWidth = 0
            for child in children
              child = $(child)
              scrollerWidth += child.outerWidth()
            self._scroller.width(scrollerWidth)

          # Set total height
          if self._options.scrollY
            scrollerHeight = 0
            for child in children
              child = $(child)
              scrollerHeight += child.outerHeight()
            self._scroller.height(scrollerHeight)

      _position: (x, y) ->
        cls = this.constructor
        self = this
        x = if self._scrollX then x else 0
        y = if self._scrollY then y else 0
        self._scroller.translate(x, y)
        self._x = x
        self._y = y
        self

      _resetPosition: (duration=0) ->
        self = this
        resetX = number.threshold(self._x, self._maxScrollX, self._minScrollX)
        resetY = number.threshold(self._y, self._maxScrollY, self._minScrollY)

        if resetX == self._x and resetY == self._y
          if self._moved
            self._moved = false
          return

        self.scrollTo(resetX, resetY, duration)

      _ensureScroller: ->
        children = this.element.children()
        scroller = this._ensureWrapper("scroller")
        if children.length > 0
          children.appendTo(scroller)
        scroller

      _animate: ->
        cls = this.constructor
        self = this
        return if self._animating
        if not self._steps.length
          self._resetPosition(400)
          return self

        startX = self._x
        startY = self._y
        startTime = new Date().getTime()
        step = self._steps.shift()
        step.duration = 0 if step.x == startX and step.y == startY
        self._animating = true
        self._moved = true
        self._duration(step.duration)._position(step.x, step.y)
        self._animating = false
        if step.duration
          transitionEndFn = (e) ->
            e.preventDefault()
            e.stopPropagation()
            self.emit cls.TRANSITION_END_EVENT
          self._scroller.bind events.WEBKIT_TRANSITION_END_EVENT, transitionEndFn
        else
          self._resetPosition(0)
        self

      _stopAnimation: ->
        this._steps = []
        this._moved = false
        this._animating = false
        this

      ###
      Get position where scroller should snap to

      ###
      _snapPosition: (x, y, duration, reset=false) ->
        throw new exceptions.NotImplementedError()

      ###
      Implement in subclasses
      ###
      _snap: (x, y) ->
        throw new exceptions.NotImplementedError()

      # Thx iScroll
      _momentum: (dist, time, maxDistUpper, maxDistLower, size) ->
        deceleration = this._options.deceleration
        speed = math.abs(dist) / time
        newDist = (speed * speed) / (2 * deceleration)
        newTime = 0
        outsideDist = 0

        # Proportinally reduce speed if we are outside of the boundaries
        if dist > 0 and newDist > maxDistUpper
          outsideDist = size / (6 / (newDist / speed * deceleration))
          maxDistUpper = maxDistUpper + outsideDist
          speed = speed * maxDistUpper / newDist
          newDist = maxDistUpper
        else if dist < 0 and newDist > maxDistLower
          outsideDist = size / (6 / (newDist / speed * deceleration))
          maxDistLower = maxDistLower + outsideDist
          speed = speed * maxDistLower / newDist
          newDist = maxDistLower

        # FIXME Here is a workaround to fix negative duration problem
        speed = math.min(1, math.abs(speed))
        newDist = math.min(200, newDist)
        newDist = newDist * (if dist < 0 then -1 else 1)
        newTime = math.min(speed / deceleration, 1000)

        dist: newDist
        time: math.round(newTime)

      # Set transition duration for scroller
      _duration: (duration) ->
        this._scroller.duration(duration)
        this

    exports.Scrollable = Scrollable
