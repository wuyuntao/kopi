define "kopi/ui/clickable", (require, exports, module) ->

  events = require "kopi/utils/events"
  touchable = require "kopi/ui/touchable"
  logging = require "kopi/logging"

  logger = logging.logger(module.id)
  math = Math

  ###
  A base widget responsive to click, hold, hover and other button-like behaviors
  ###
  class Clickable extends touchable.Touchable

    @HOVER_EVENT = "hover"
    @HOVER_OUT_EVENT = "hoverout"
    @CLICK_EVENT = "click"
    @DOUBALE_CLICK_EVENT = "doubleclick"
    @TOUCH_HOLD_EVENT = "touchhold"
    @EVENT_NAMESPACE = "clickable"

    @widgetName "Clickable"

    @configure
      # @type   {Integer}   holdTime      time for touch and hold event
      holdTime: 2000
      # @type   {Integer}   moveThreshold moving distance should be ignored
      moveThreshold: 10
      # @type   {Boolean}   ignoreClick   original click event should be ignored
      ignoreClick: false
      # @type   {Integer}   lockTime      min time between trigger click event
      lockTime: 0

    constructor: ->
      super
      cls = this.constructor
      cls.HOVER_CLASS or= cls.cssClass("hover")
      cls.ACTIVE_CLASS or= cls.cssClass("active")

    delegate: ->
      super

      self = this
      preventDefault = self._options.preventDefault
      stopPropagation = self._options.stopPropagation

      mouseOverFn = (e) ->
        e.preventDefault() if preventDefault
        e.stopPropagation() if stopPropagation
        self.emit(Clickable.HOVER_EVENT, [e])
        self.element
          .bind(Clickable.eventName(events.MOUSE_OUT_EVENT), mouseOutFn)

      mouseOutFn = (e) ->
        e.preventDefault() if preventDefault
        e.stopPropagation() if stopPropagation
        self.emit(Clickable.HOVER_OUT_EVENT, [e])
        self.element
          .unbind(Clickable.eventName(events.MOUSE_OUT_EVENT))

      self.element
        .bind(Clickable.eventName(events.MOUSE_OVER_EVENT), mouseOverFn)

      if self._options.ignoreClick
        clickFn = (e) ->
          e.preventDefault()
          e.stopPropagation()
        self.element
          .bind(Clickable.eventName(events.CLICK_EVENT), clickFn)
          .bind(Clickable.eventName(events.DOUBALE_CLICK_EVENT), clickFn)
      # logger.log "[clickable:delegate] #{this}:"

    undelegate: ->
      super
      @element
        .unbind(events.MOUSE_OVER_EVENT)
        .unbind(events.CLICK_EVENT)
      # logger.log "[clickable:undelegate] #{this}:"

    ontouchstart: (e, event) ->
      cls = this.constructor
      self = this
      self._moved = false
      self._holded = false
      point = self._points(event)
      self._pointX = point.pageX
      self._pointY = point.pageY
      point = self._points(event)
      self.element.addClass(cls.ACTIVE_CLASS)
      self._setHoldTimeout()

    ontouchmove: (e, event) ->
      self = this
      threshold = self._options.moveThreshold
      point = self._points(event)
      deltaX = point.pageX - self._pointX
      deltaY = point.pageY - self._pointY
      # Only if move distance over threshold
      if not self._moved and ((math.abs(deltaX) > threshold) or (math.abs(deltaY) > threshold))
        self._moved = true
      # Reset hold timeout if touch moves
      self._setHoldTimeout()

    ontouchend: (e, event) ->
      cls = this.constructor
      self = this
      self._clearHoldTimeout()
      self.element.removeClass(cls.ACTIVE_CLASS)
      # a small distance move will trigger a click event too
      if not self._holded and not self._moved
        event.preventDefault()
        event.stopPropagation()
        if self._canEmitClickEvent()
          self.emit(cls.CLICK_EVENT, [event])

    ontouchcancel: (e, event) ->
      this.emit(this.constructor.TOUCH_END_EVENT, [event])

    onhover: (e, event) ->
      cls = this.constructor
      self = this
      self._hovered = true
      self.element.addClass(cls.HOVER_CLASS)

    onhoverout: (e, event) ->
      cls = this.constructor
      self = this
      self._hovered = false
      self.element.removeClass(cls.HOVER_CLASS)

    onclick: (e, event) ->

    ontouchhold: (e, event) ->
      cls = this.constructor
      self = this
      self._holded = true
      self.emit(cls.TOUCH_END_EVENT, [event])

    _reset: () ->
      self = this
      self._moved = false
      self._holded = false
      self._clearHoldTimeout()

    _setHoldTimeout: ->
      cls = this.constructor
      self = this
      clearTimeout(self._holdTimer) if self._holdTimer
      holdFn = ->
        self.emit(cls.TOUCH_HOLD_EVENT) if self._canEmitTouchHoldEvent()
      self._holdTimer = setTimeout holdFn, self._options.holdTime

    _clearHoldTimeout: ->
      self = this
      if self._holdTimer
        clearTimeout(self._holdTimer)
        self._holdTimer = null

    _canEmitClickEvent: ->
      return true unless @_options.lockTime > 0
      now = new Date().getTime()
      canEmit = !(@_clickLock + @_options.lockTime > now)
      # Update lock
      if canEmit
        @_clickLock = now
      else
        logger.warn "[clickable:_canEmitClickEvent] #{this}: is locked"
      canEmit

    _canEmitTouchHoldEvent: ->
      # Share the same lock with click event
      @_canEmitClickEvent()

  Clickable: Clickable
