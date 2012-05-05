define "kopi/ui/scrollable", (require, exports, module) ->

  $ = require "jquery"
  exceptions = require "kopi/exceptions"
  logging = require "kopi/logging"
  events = require "kopi/utils/events"
  css = require "kopi/utils/css"
  klass = require "kopi/utils/klass"
  support = require "kopi/utils/support"
  text = require "kopi/utils/text"
  number = require "kopi/utils/number"
  touchable = require "kopi/ui/touchable"

  math = Math
  logger = logging.logger(module.id)

  TRANSITION_PROPERTY = css.experimental("transition-property")
  TRANSITION_TIMING_FUNCTION = css.experimental("transition-timing-function")
  TRANSFORM_ORIGIN = css.experimental("transform-origin")
  TRANSFORM = css.experimental("transform")

  ###
  TODO Support legacy animation
  TODO Do not calculate data on axis not scrollable
  TODO Handle animation of X axis and Y axis independently

  ###
  class Scrollable extends touchable.Touchable

    kls = this

    kls.widgetName "Scrollable"

    kls.CLICK_EVENT = "click"
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
      snap: false
      snapThreshold: 1
      throttle: 250

    proto = kls.prototype
    klass.reader proto, "container"
    klass.reader proto, "containerWidth"
    klass.reader proto, "containerHeight"
    klass.reader proto, "elementWidth"
    klass.reader proto, "elementHeight"

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
      self

    onskeleton: ->
      this._container or= this._ensureWrapper("container")
      super

    onresize: ->
      this
        ._elementSize()
        ._containerSize()
        ._scrollSize()
        ._duration(0)
        ._resetPosition(100)

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
        matrix = self._container.parseMatrix()
        if matrix and (matrix.x != self._x or matrix.y != self._y)
          self._container.unbind(events.WEBKIT_TRANSITION_END_EVENT)
          self._steps = []
          self._position(matrix.x, matrix.y)

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
      if self._minScrollX? and self._maxScrollX? and (self._minScrollX < newX or newX < self._maxScrollX)
        newX = if options.bounce
            self._x + deltaX * options.damping
          else if newX >= self._minScrollX or self._maxScrollX >= self._minScrollX
            self._minScrollX
          else
            self._maxScrollX

      if self._minScrollY? and self._maxScrollY? and (self._minScrollY < newY or newY < self._maxScrollY)
        newY = if options.bounce
            self._y + deltaY * options.damping
          else if newY >= self._minScrollY or self._maxScrollY >= self._minScrollY
            self._minScrollY
          else
            self._maxScrollY

      self._moved = true
      self._position(newX, newY)

      # Reset start time and position if mouse or finger stops for a while
      if timestamp - self._startTime > options.throttle
        self._startTime = timestamp
        self._startX = self._x
        self._startY = self._y

    ontouchend: (e, event) ->
      cls = this.constructor
      self = this
      point = self._points(event)
      # return if support.touch and event.touches.length

      if not self._moved
        self.emit(cls.CLICK_EVENT, [event])
        return

      event.preventDefault()
      event.stopPropagation()

      options = self._options
      momentum =
        distX: 0
        distY: 0
        duration: 0
      duration = (point.timeStamp or new Date().getTime()) - self._startTime
      newX = self._x
      newY = self._y

      if duration < options.throttle and options.momentum
        momentum = self._momentum(newX - self._startX
          , newY - self._startY
          , duration
          , (if self._minScrollX? then self._minScrollX - self._x else null)
          , (if self._maxScrollX? then self._x - self._maxScrollX else null)
          , (if self._minScrollY? then self._minScrollY - self._y else null)
          , (if self._maxScrollY? then self._y - self._maxScrollY else null)
          , (if options.bounce then self._elementWidth else 0)
          , (if options.bounce then self._elementHeight else 0))
        newX = self._x + momentum.distX
        newY = self._y + momentum.distY

        if (self._x > self._minScrollX and newX > self._minScrollX) or (self.x < self._maxScrollX and newX < self._maxScrollX)
          momentum.distX = 0
        if (self._y > self._minScrollY and newY > self._minScrollY) or (self._y < self._maxScrollY and newY < self._maxScrollY)
          momentum.distY = 0


      if momentum.distX or momentum.distY
        newDuration = math.max(momentum.duration, 10)
        if options.snap
          # TODO Should we switch to `newDuration`
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

    ontransitionend: (e, event) ->
      cls = this.constructor
      self = this
      self._container.unbind(events.WEBKIT_TRANSITION_END_EVENT)
      self._animate()

    ###
    Get size of element
    ###
    _elementSize: ->
      self = this
      self._elementWidth = self.element.innerWidth()
      self._elementHeight = self.element.innerHeight()
      elementOffset = self.element.offset()
      self._elementOffsetLeft = -elementOffset.left
      self._elementOffsetTop = -elementOffset.top
      self

    ###
    Calculate size of container
    ###
    _containerSize: ->
      self = this
      children = self._container.children()
      if children.length > 0

        # Set total width
        if self._options.scrollX
          containerWidth = 0
          for child in children
            child = $(child)
            containerWidth += child.outerWidth()
          self._container.width(containerWidth)
        else
          self._container.width(self._elementWidth)

        # Set total height
        if self._options.scrollY
          containerHeight = 0
          for child in children
            child = $(child)
            containerHeight += child.outerHeight()
          self._container.height(containerHeight)
        else
          self._container.height(self._elementHeight)

      # FIXME Actual size of container should be greater than element?
      self._containerWidth = math.max(self._container.outerWidth(), self._elementWidth)
      self._containerHeight = math.max(self._container.outerHeight(), self._elementHeight)
      self

    ###
    Calculate scroll size
    ###
    _scrollSize: ->
      self = this
      self._minScrollX = 0
      self._minScrollY = 0
      self._maxScrollX = self._elementWidth - self._containerWidth
      self._maxScrollY = self._elementHeight - self._containerHeight

      self._scrollX = self._options.scrollX and self._maxScrollX < self._minScrollX
      self._scrollY = self._options.scrollY and self._maxScrollY < self._minScrollY

      self._directionX = 0
      self._directionY = 0
      self

    _position: (x, y) ->
      cls = this.constructor
      self = this
      x = if self._scrollX then x else 0
      y = if self._scrollY then y else 0
      self._container.translate(x, y)
      self._x = x
      self._y = y
      self

    _resetPosition: (duration=0) ->
      self = this
      if self._minScrollX? and self._maxScrollX?
        resetX = number.threshold(self._x, self._maxScrollX, self._minScrollX)
      else
        resetX = self._x
      if self._minScrollY? and self._maxScrollY?
        resetY = number.threshold(self._y, self._maxScrollY, self._minScrollY)
      else
        resetY = self._y

      if resetX == self._x and resetY == self._y
        if self._moved
          self._moved = false
        return

      self.scrollTo(resetX, resetY, duration)

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
        self._container.bind events.WEBKIT_TRANSITION_END_EVENT, transitionEndFn
      else
        self._resetPosition(0)
      self

    _stopAnimation: ->
      this._steps = []
      this._moved = false
      this._animating = false
      this

    ###
    Get position where container should snap to

    ###
    _snapPosition: (x, y, duration, reset=false) ->
      throw new exceptions.NotImplementedError()

    ###
    Implement in subclasses
    ###
    _snap: (x, y) ->
      throw new exceptions.NotImplementedError()

    ###
    Calculate momentum distance and duration
    ###
    _momentum: (distX, distY, duration, minDistX, maxDistX, minDistY, maxDistY, sizeX, sizeY) ->
      self = this
      # Calculate speed
      speedX = math.abs(distX) / duration
      speedY = math.abs(distY) / duration
      speed = math.sqrt(math.pow(speedX, 2) + math.pow(speedY, 2))
      maxSpeed = math.sqrt(math.pow(self._containerWidth, 2) + math.pow(self._containerHeight, 2)) / 500
      if speed > maxSpeed
        newSpeed = maxSpeed
        speedX = newSpeed / speed * speedX
        speedY = newSpeed / speed * speedY
        speed = newSpeed
      # Calculate distance
      deceleration = self._options.deceleration
      newDistX = math.pow(speedX, 2) / (2 * deceleration)
      newDistY = math.pow(speedY, 2) / (2 * deceleration)
      outsideDistX = 0

      if minDistX? and distX > 0 and newDistX > minDistX
        [speedX, newDistX] = self._outside(newDistX, speedX, sizeX, minDistX, deceleration)
      if maxDistX? and distX < 0 and newDistX > maxDistX
        [speedX, newDistX] = self._outside(newDistX, speedX, sizeX, maxDistX, deceleration)
      if minDistY? and distY > 0 and newDistY > minDistY
        [speedY, newDistY] = self._outside(newDistY, speedY, sizeY, minDistY, deceleration)
      if maxDistY? and distY < 0 and newDistY > maxDistY
        [speedY, newDistY] = self._outside(newDistY, speedY, sizeY, maxDistY, deceleration)

      # FIXME Here is a workaround to fix negative duration problem
      newDistX = math.min(200, newDistX) * (if distX < 0 then -1 else 1)
      newDistY = math.min(200, newDistY) * (if distY < 0 then -1 else 1)
      speed = math.min(1, math.sqrt(math.pow(speedX, 2) + math.pow(speedY, 2)))
      newDuration = math.min(speed / deceleration, 1000)

      distX: newDistX
      distY: newDistY
      duration: newDuration

    ###
    Re-calculate speed and distance if target is outside container
    ###
    _outside: (distance, speed, size, maxDistance, deceleration) ->
      outsideDistance = size / (6 / (distance / speed * deceleration))
      maxDistance = maxDistance + outsideDistance
      speed = speed * maxDistance / distance
      distance = maxDistance
      [speed, distance]

    # Set transition duration for container
    _duration: (duration) ->
      this._container.duration(duration)
      this

  Scrollable: Scrollable
