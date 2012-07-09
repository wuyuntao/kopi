define "kopi/ui/touchable", (require, exports, module) ->

  $ = require "jquery"
  events = require "kopi/utils/events"
  support = require "kopi/utils/support"
  widgets = require "kopi/ui/widgets"

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
      this._gestures = (new gesture(this, options) for gesture in options.gestures)

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
        this._callGestures(kls.TOUCH_MOVE_EVENT, e)

      touchEndFn = (e) =>
        doc
          .unbind(kls.eventName(events.TOUCH_MOVE_EVENT))
          .unbind(kls.eventName(events.TOUCH_END_EVENT))
          .unbind(kls.eventName(events.TOUCH_CANCEL_EVENT))

        this._callGestures(kls.TOUCH_END_EVENT, e)

      touchCancelFn = (e) =>
        doc
          .unbind(kls.eventName(events.TOUCH_MOVE_EVENT))
          .unbind(kls.eventName(events.TOUCH_END_EVENT))
          .unbind(kls.eventName(events.TOUCH_CANCEL_EVENT))

        this._callGestures(kls.TOUCH_CANCEL_EVENT, e)

      touchStartFn = (e) =>
        this._callGestures(kls.TOUCH_START_EVENT, e)

        doc
          .bind(kls.eventName(events.TOUCH_MOVE_EVENT), touchMoveFn)
          .bind(kls.eventName(events.TOUCH_END_EVENT), touchEndFn)
          .bind(kls.eventName(events.TOUCH_CANCEL_EVENT), touchCancelFn)

      this.element
        .bind(events.TOUCH_START_EVENT, touchStartFn)

    undelegate: ->
      this.element.unbind(events.TOUCH_START_EVENT)

    _callGestures: (name, event) ->
      for gesture in this._gestures
        method = gesture["on" + name]
        break if method and method.call(gesture, event) == false
      return

  Touchable: Touchable
