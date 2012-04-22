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

    kls.configure
      preventDefault: false
      stopPropagation: false
      multiTouch: false

    onskeleton: ->
      this.delegate()
      super

    delegate: ->
      cls = this.constructor
      self = this
      preventDefault = self._options.preventDefault
      stopPropagation = self._options.stopPropagation

      touchMoveFn = (e) ->
        # TODO What to do if widget is locked?
        e.preventDefault() if preventDefault
        e.stopPropagation() if stopPropagation
        self.emit(cls.TOUCH_MOVE_EVENT, [e])

      touchEndFn = (e) ->
        # TODO What to do if widget is locked?
        e.preventDefault() if preventDefault
        e.stopPropagation() if stopPropagation
        doc
          .unbind(kls.eventName(events.TOUCH_MOVE_EVENT))
          .unbind(kls.eventName(events.TOUCH_END_EVENT))
          .unbind(kls.eventName(events.TOUCH_CANCEL_EVENT))
        self.emit(cls.TOUCH_END_EVENT, [e])

      touchCancelFn = (e) ->
        # TODO What to do if widget is locked?
        e.preventDefault() if preventDefault
        e.stopPropagation() if stopPropagation
        doc
          .unbind(kls.eventName(events.TOUCH_MOVE_EVENT))
          .unbind(kls.eventName(events.TOUCH_END_EVENT))
          .unbind(kls.eventName(events.TOUCH_CANCEL_EVENT))
        self.emit(cls.TOUCH_CANCEL_EVENT, [e])

      touchStartFn = (e) ->
        return if self.locked or not events.isLeftClick(e)
        e.preventDefault() if preventDefault
        e.stopPropagation() if stopPropagation
        self.emit(cls.TOUCH_START_EVENT, [e])
        doc
          .bind(kls.eventName(events.TOUCH_MOVE_EVENT), touchMoveFn)
          .bind(kls.eventName(events.TOUCH_END_EVENT), touchEndFn)
          .bind(kls.eventName(events.TOUCH_CANCEL_EVENT), touchCancelFn)

      self.element
        .bind(events.TOUCH_START_EVENT, touchStartFn)

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
