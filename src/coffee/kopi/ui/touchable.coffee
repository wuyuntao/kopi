define "kopi/ui/touchable", (require, exports, module) ->

  $ = require "jquery"
  events = require "kopi/utils/events"
  support = require "kopi/utils/support"
  widgets = require "kopi/ui/widgets"
  Map = require("kopi/utils/structs/map").Map
  logging = require "kopi/logging"

  logger = logging.logger(module.id)
  doc = $(document)
  math = Math

  ###
  A widget supports touch events
  ###
  class Touchable extends widgets.Widget

    @TOUCH_START_EVENT = "touchstart"
    @TOUCH_MOVE_EVENT = "touchmove"
    @TOUCH_END_EVENT = "touchend"
    @TOUCH_CANCEL_EVENT = "touchcancel"
    @EVENT_NAMESPACE = "touchable"

    @DIRECTION_UP = "up"
    @DIRECTION_DOWN = "down"
    @DIRECTION_LEFT = "left"
    @DIRECTION_RIGHT = "right"

    ###
    Calculate the angle between two points

    @param {Object} pos1 { x: int, y: int }
    @param {Object} pos2 { x: int, y: int }
    @return {Number} angle
    ###
    @angle = (pos1, pos2) ->
      distance = @distance(pos1, pos2)
      @angleByDistance(distance)

    ###
    Calculate the angle between two points via their distance

    @param {Object} distance { distX: int, distY: int }
    @return {Number} angle
    ###
    @angleByDistance = (distance) ->
      math.atan2(distance.distY, distance.distX) * 180 / math.PI

    ###
    Calculate the scale size between two fingers

    @param {Object} pos1 { x: int, y: int }
    @param {Object} pos2 { x: int, y: int }
    @return {Number} scale
    ###
    @scale = (pos1, pos2) ->
      if pos1.length >= 2 and pos2.length >= 2

        x = pos1[0].x - pos1[1].x
        y = pos1[0].y - pos1[1].y
        startDistance = math.sqrt((x*x) + (y*y))

        x = pos2[0].x - pos2[1].x
        y = pos2[0].y - pos2[1].y
        endDistance = math.sqrt((x*x) + (y*y))

        return endDistance / startDistance

      return 0

    ###
    calculate mean center of multiple positions
    ###
    @center = (positions) ->
      return positions[0] if positions.length <= 1

      sumX = 0
      sumY = 0
      for pos in positions
        sumX += pos.x
        sumY += pos.y
      x: sumX / positions.length
      y: sumY / positions.length

    ###
    calculate the rotation degrees between two fingers

    @param {Object} pos1 { x: int, y: int }
    @param {Object} pos2 { x: int, y: int }
    @return {Number} rotation
    ###
    @rotation = (pos1, pos2) ->
      if pos1.length == 2 and pos2.length == 2
        x = pos1[0].x - pos1[1].x
        y = pos1[0].y - pos1[1].y
        startRotation = math.atan2(y, x) * 180 / math.PI
        x = pos2[0].x - pos2[1].x
        y = pos2[0].y - pos2[1].y
        endRotation = math.atan2(y, x) * 180 / math.PI
        return endRotation - startRotation
      return 0

    ###
    Get the angle to direction define

    @param {Number} angle
    @return {String} direction
    ###
    @direction = (angle) ->
      if angle >= 45 and angle < 135
        return @DIRECTION_DOWN
      else if angle >= 135 or angle <= -135
        return @DIRECTION_LEFT
      else if angle < -45 and angle > -135
        return @DIRECTION_UP
      else
        return @DIRECTION_RIGHT

    ###
    Calculate average distance between to points

    @param {Object}  pos1 { x: int, y: int }
    @param {Object}  pos2 { x: int, y: int }
    ###
    @distance = (pos1, pos2) ->
      sumX = 0
      sumY = 0
      sum = 0
      len = math.min(pos1.length, pos2.length)
      for i in [0...len]
        pos1i = pos1[i]
        pos2i = pos2[i]
        x = pos2i.x - pos1i.x
        y = pos2i.y - pos1i.y
        sumX += x
        sumY += y
        sum += math.sqrt(x * x + y * y)

      distX: sumX / len
      distY: sumY / len
      dist: sum / len

    @distanceX = (pos1, pos2) ->
      math.abs(pos1.x - pos2.x)

    @distanceY = (pos1, pos2) ->
      math.abs(pos1.y - pos2.y)

    ###
    get the x and y positions from the event object

    @param {Event} event
    @return {Array}  [{ x: int, y: int }]
    ###
    @position = (e) ->
      # no touches, use the event pageX and pageY
      if not support.touch
        pos = [{
          x: e.pageX
          y: e.pageY
        }]

      # multitouch, return array with positions
      else
        e = if e then e.originalEvent else win.event

        touches = if e.touches.length > 0 then e.touches else e.changedTouches
        pos = ({x: touch.pageX, y: touch.pageY} for touch in touches)

      pos

    @points = (e) ->
      e = if e and e.originalEvent then e.originalEvent else win.event
      if support.touch
        if e.type == events.TOUCH_END_EVENT then e.changedTouches else e.touches
      else
        [e]

    ###
    Count the number of fingers in the event
    when no fingers are detected, one finger is returned (mouse pointer)

    @param {Event} event
    @return {Number}
    ###
    @fingers = (e) ->
      e = if e and e.originalEvent then e.originalEvent else win.event
      if e.touches then e.touches.length else 1

    @widgetName "Touchable"

    @configure
      preventDefault: false
      stopPropagation: false
      gestures: []

    constructor: ->
      super
      options = this._options
      this._gestures = new Map()
      for gesture in options.gestures
        this.addGesture(new gesture(this, options))
      return

    onrender: ->
      # logger.log "[touchable:onrender] #{this}"
      this.delegate()
      super

    ondestroy: ->
      # logger.log "[touchable:ondestroy] #{this}"
      this.undelegate()
      super

    delegate: ->
      # TODO
      # What to do if widget is locked?
      #
      # -- wuyuntao, 2012-07-09
      touchMoveFn = (e) =>
        this.emit(Touchable.TOUCH_MOVE_EVENT, [e])

      touchEndFn = (e) =>
        doc
          .unbind(Touchable.eventName(events.TOUCH_MOVE_EVENT))
          .unbind(Touchable.eventName(events.TOUCH_END_EVENT))
          .unbind(Touchable.eventName(events.TOUCH_CANCEL_EVENT))

        this.emit(Touchable.TOUCH_END_EVENT, [e])

      touchCancelFn = (e) =>
        doc
          .unbind(Touchable.eventName(events.TOUCH_MOVE_EVENT))
          .unbind(Touchable.eventName(events.TOUCH_END_EVENT))
          .unbind(Touchable.eventName(events.TOUCH_CANCEL_EVENT))

        this.emit(Touchable.TOUCH_CANCEL_EVENT, [e])

      touchStartFn = (e) =>
        this.emit(Touchable.TOUCH_START_EVENT, [e])

        doc
          .bind(Touchable.eventName(events.TOUCH_MOVE_EVENT), touchMoveFn)
          .bind(Touchable.eventName(events.TOUCH_END_EVENT), touchEndFn)
          .bind(Touchable.eventName(events.TOUCH_CANCEL_EVENT), touchCancelFn)

      this.element
        .bind(events.TOUCH_START_EVENT, touchStartFn)
      logger.log "[touchable:delegate] #{this}"

    undelegate: ->
      this.element.unbind(events.TOUCH_START_EVENT)
      logger.log "[touchable:undelegate] #{this}"

    addGesture: (gesture) ->
      this._gestures.set(gesture.guid, gesture)
      gesture

    removeGesture: (gesture) ->
      this._gestures.remove(gesture.guid)
      gesture

    ontouchstart: (e, event) ->
      this._callGestures(this.constructor.TOUCH_START_EVENT, event)

    ontouchmove: (e, event) ->
      this._callGestures(this.constructor.TOUCH_MOVE_EVENT, event)

    ontouchend: (e, event) ->
      this._callGestures(this.constructor.TOUCH_END_EVENT, event)

    ontouchcancel: (e, event) ->
      this._callGestures(this.constructor.TOUCH_CANCEL_EVENT, event)

    _callGestures: (name, event) ->
      this._gestures.forEach (key, gesture) ->
        method = gesture["on" + name]
        if method
          method.call(gesture, event) if method
      return

    ###
    Get point from event
    ###
    _points: (event) ->
      cls = this.constructor
      points = cls.points(event)
      return (if @_options.multitouch then points else points[0])

  Touchable: Touchable
