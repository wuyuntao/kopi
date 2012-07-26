define "kopi/ui/touchable", (require, exports, module) ->

  $ = require "jquery"
  events = require "kopi/utils/events"
  support = require "kopi/utils/support"
  widgets = require "kopi/ui/widgets"
  Map = require("kopi/utils/structs/map").Map

  doc = $(document)

  ###
  A widget supports touch events
  ###
  class Touchable extends widgets.Widget

    kls = this
    kls.TOUCH_START_EVENT = "touchstart"
    kls.TOUCH_MOVE_EVENT = "touchmove"
    kls.TOUCH_END_EVENT = "touchend"
    kls.TOUCH_CANCEL_EVENT = "touchcancel"
    kls.EVENT_NAMESPACE = "touchable"

    kls.widgetName "Touchable"

    kls.configure
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
      this.delegate()
      super

    ondestroy: ->
      this.undelegate()
      super

    delegate: ->
      cls = this.constructor
      # TODO
      # What to do if widget is locked?
      #
      # -- wuyuntao, 2012-07-09
      touchMoveFn = (e) =>
        this.emit(kls.TOUCH_MOVE_EVENT, [e])

      touchEndFn = (e) =>
        doc
          .unbind(kls.eventName(events.TOUCH_MOVE_EVENT))
          .unbind(kls.eventName(events.TOUCH_END_EVENT))
          .unbind(kls.eventName(events.TOUCH_CANCEL_EVENT))

        this.emit(kls.TOUCH_END_EVENT, [e])

      touchCancelFn = (e) =>
        doc
          .unbind(kls.eventName(events.TOUCH_MOVE_EVENT))
          .unbind(kls.eventName(events.TOUCH_END_EVENT))
          .unbind(kls.eventName(events.TOUCH_CANCEL_EVENT))

        this.emit(kls.TOUCH_CANCEL_EVENT, [e])

      touchStartFn = (e) =>
        this.emit(kls.TOUCH_START_EVENT, [e])

        doc
          .bind(kls.eventName(events.TOUCH_MOVE_EVENT), touchMoveFn)
          .bind(kls.eventName(events.TOUCH_END_EVENT), touchEndFn)
          .bind(kls.eventName(events.TOUCH_CANCEL_EVENT), touchCancelFn)

      this.element
        .bind(events.TOUCH_START_EVENT, touchStartFn)

    undelegate: ->
      this.element.unbind(events.TOUCH_START_EVENT)

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
      event = event.originalEvent
      if support.touch
        touches = if event.type == events.TOUCH_END_EVENT then event.changedTouches else event.touches
        if this._options.multiTouch then touches else touches[0]
      else
        if this._options.multiTouch then [event] else event

  Touchable: Touchable
