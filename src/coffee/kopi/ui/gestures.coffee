define "kopi/ui/gestures", (require, exports, module) ->

  EventEmitter = require("kopi/events").EventEmitter
  klass = require "kopi/utils/klass"
  support = require "kopi/utils/support"

  win = window
  doc = document
  body = doc.body
  math = Math

  ###
  Base class for concrete gesture recognizer classes.

  A gesture recognizer decouples the logic for recognizing a gesture
  and acting on that recognition

  This is inspired by UIGestureRecognizer of iOS

  ###
  class Base extends EventEmitter

    klass.configure this,
      preventDefault: true
      stopPropagation: false

    constructor: (widget, options={}) ->
      this._widget = widget
      this.configure(options)

    ontouchstart: (e) ->
      e.preventDefault() if this._options.preventDefault
      e.stopPropagation() if this._options.stopPropagation

    ontouchmove: (e) ->
      e.preventDefault() if this._options.preventDefault
      e.stopPropagation() if this._options.stopPropagation

    ontouchend: (e) ->
      e.preventDefault() if this._options.preventDefault
      e.stopPropagation() if this._options.stopPropagation

    ontouchcancel: (e) -> this.ontouchend.call(this, e)

    ###
    get the x and y positions from the event object

    @param {Event} event
    @return {Array}  [{ x: int, y: int }]
    ###
    _getPositionfromEvent: (e, multiTouch=false) ->
      e or= win.event

      # no touches, use the event pageX and pageY
      if not support.touch
        pos = [{
          x: e.pageX
          y: e.pageY
        }]

      # multitouch, return array with positions
      else
        touches = if e.touches.length > 0 then e.touches else e.changedTouches
        pos = ({x: touch.pageX, y: touch.pageY} for touch in touches)

      if multiTouch then pos else pos[0]


  ###
  Tap Gesture Recognizer

  ###
  class Tap extends Base

    this.TAP_START = "tapstart"
    this.TAP_EVENT = "tap"
    this.TAP_HOLD_EVENT = "taphold"
    this.TAP_RELEASE_EVENT = "taprelease"

    this.configure
      # @type  {Number}
      minTaps: 1
      # @type  {Number}
      minTouches: 1
      # @type  {Number} pixels
      movement: 20
      # @type  {Number} ms
      timeout: 500

    ontouchstart: (e) ->
      super
      this._moved = false
      this._holded = false
      pos = this._getPositionfromEvent(e, false)
      this._posX = pos.x
      this._posY = pos.y
      this._widget.emit(this.constructor.TAP_START, [e])
      this._setHoldTimeout()

    ontouchmove: (e) ->
      super
      threshold = this._options.movement
      pos = this._getPositionfromEvent(e, false)
      deltaX = pos.x - this._posX
      deltaY = pos.y - this._posY
      # Only if move distance over threshold
      if not this._moved and ((math.abs(deltaX) > threshold) or (math.abs(deltaY) > threshold))
        this._moved = true
      if not this._holded
        # Reset hold timeout if touch moves
        this._setHoldTimeout()

    ontouchend: (e) ->
      super
      this._clearHoldTimeout()
      this._widget.emit(this.constructor.TAP_RELEASE_EVENT)
      if not this._holded and not this._moved
        if e
          e.preventDefault()
          e.stopPropagation()
        this._widget.emit(this.constructor.TAP_EVENT)
        return false

    _setHoldTimeout: ->
      clearTimeout(this._holdTimer) if this._holdTimer
      holdFn = =>
        this._holded = true
        this._widget.emit(this.constructor.TAP_HOLD_EVENT)
        this._clearHoldTimeout()
      this._holdTimer = setTimeout(holdFn, this._options.timeout)

    _clearHoldTimeout: ->
      if this._holdTimer
        clearTimeout(this._holdTimer)
        this._holdTimer = null


  class Pan extends Base

    # ondragstart: ->
    # ondrag: ->
    # ondragend: ->
    # onswipe: ->
    # onswipeleft: ->
    # onswiperight: ->
    # onrelease: ->


  class Pinch extends Base

    # onpinchstart: ->
    # onpinch: ->
    # onpinchend: ->
    # onrelease: ->


  class Rotation extends Base

    # onrotatestart: ->
    # onrotate: ->
    # onrotateend: ->
    # onrelease: ->


  Base: Base
  Tap: Tap
  Pinch: Pinch
  Rotation: Rotation
  Pan: Pan
