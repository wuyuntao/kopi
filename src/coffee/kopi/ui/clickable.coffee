define "kopi/ui/clickable", (require, exports, module) ->

  events = require "kopi/utils/events"
  touchable = require "kopi/ui/touchable"

  math = Math

  ###
  A base widget responsive to click, hold, hover and other button-like behaviors
  ###
  class Clickable extends touchable.Touchable

    kls = this
    kls.HOVER_EVENT = "hover"
    kls.HOVER_OUT_EVENT = "hoverout"
    kls.CLICK_EVENT = "click"
    kls.TOUCH_HOLD_EVENT = "touchhold"
    kls.EVENT_NAMESPACE = "clickable"

    this.widgetName "Clickable"

    kls.configure
      # @type   {Integer}   holdTime      time for touch and hold event
      holdTime: 2000
      # @type   {Integer}   moveThreshold moving distance should be ignored
      moveThreshold: 10
      # @type   {Function}  onhover       custom callback function
      onhover: null
      # @type   {Function}  onhoverout    custom callback function
      onhoverout: null
      # @type   {Function}  onclick       custom callback function
      onclick: null
      # @type   {Function}  ontouchhold   custom callback function
      ontouchhold: null

    constructor: ->
      super
      cls = this.constructor
      cls.HOVER_CLASS or= cls.cssClass("hover")
      cls.ACTIVE_CLASS or= cls.cssClass("active")

    delegate: ->
      super
      cls = this.constructor
      self = this
      preventDefault = self._options.preventDefault
      stopPropagation = self._options.stopPropagation

      mouseOverFn = (e) ->
        e.preventDefault() if preventDefault
        e.stopPropagation() if stopPropagation
        self.emit(cls.HOVER_EVENT, [e])
        self.element
          .bind(kls.eventName(events.MOUSE_OUT_EVENT), mouseOutFn)

      mouseOutFn = (e) ->
        e.preventDefault() if preventDefault
        e.stopPropagation() if stopPropagation
        self.emit(cls.HOVER_OUT_EVENT, [e])
        self.element
          .unbind(kls.eventName(events.MOUSE_OUT_EVENT))

      self.element
        .bind(kls.eventName(events.MOUSE_OVER_EVENT), mouseOverFn)

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
      super

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
      super

    ontouchend: (e, event) ->
      cls = this.constructor
      self = this
      self._clearHoldTimeout()
      self.element.removeClass(cls.ACTIVE_CLASS)
      # a small distance move will trigger a click event too
      if not self._holded and not self._moved
        event.preventDefault()
        event.stopPropagation()
        self.emit(cls.CLICK_EVENT, [event])
      super

    ontouchcancel: (e, event) ->
      this.emit(this.constructor.TOUCH_END_EVENT, [event])
      super

    onhover: (e, event) ->
      cls = this.constructor
      self = this
      self._hovered = true
      self.element.addClass(cls.HOVER_CLASS)
      self._callback(cls.HOVER_EVENT)

    onhoverout: (e, event) ->
      cls = this.constructor
      self = this
      self._hovered = false
      self.element.removeClass(cls.HOVER_CLASS)
      self._callback(cls.HOVER_OUT_EVENT)

    onclick: (e, event) ->
      this._callback(this.constructor.CLICK_EVENT, arguments)

    ontouchhold: (e, event) ->
      cls = this.constructor
      self = this
      self._holded = true
      self.emit(cls.TOUCH_END_EVENT, [event])
      self._callback(cls.TOUCH_HOLD_EVENT, arguments)

    _reset: () ->
      self = this
      self._moved = false
      self._holded = false
      self._clearHoldTimeout()

    _setHoldTimeout: ->
      cls = this.constructor
      self = this
      clearTimeout(self._holdTimer) if self._holdTimer
      holdFn = -> self.emit(cls.TOUCH_HOLD_EVENT)
      self._holdTimer = setTimeout holdFn, self._options.holdTime

    _clearHoldTimeout: ->
      self = this
      if self._holdTimer
        clearTimeout(self._holdTimer)
        self._holdTimer = null

  Clickable: Clickable
