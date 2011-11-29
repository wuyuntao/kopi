kopi.module("kopi.ui.touchable")
  .require("kopi.utils.events")
  .require("kopi.utils.support")
  .require("kopi.ui.widgets")
  .define (exports, events, support, widgets) ->

    ###
    A widget supports touch events
    ###
    class Touchable extends widgets.Widget

      kls = this
      kls.TOUCH_START_EVENT = "touchstart"
      kls.TOUCH_MOVE_EVENT = "touchmove"
      kls.TOUCH_END_EVENT = "touchend"
      kls.TOUCH_CANCEL_EVENT = "touchcancel"
      kls.TRANSITION_END_EVENT = "transitionend"

      this.configure
        preventDefault: true
        stopPropagation: true
        multiTouch: false

      ondelegate: ->
        cls = this.constructor
        self = this
        preventDefault = self._options.preventDefault
        stopPropagation = self._options.stopPropagation

        touchStartFn = (e) ->
          return if self.locked
          # TODO return if not events.isLeftButton(e)
          e.preventDefault() if preventDefault
          e.stopPropagation() if stopPropagation
          self.emit(cls.TOUCH_START_EVENT, [self._points(e)])
          self.element
            .bind(events.TOUCH_MOVE_EVENT, touchMoveFn)
            .bind(events.TOUCH_END_EVENT, touchEndFn)
            .bind(events.TOUCH_CANCEL_EVENT, touchCancelFn)

        touchMoveFn = (e) ->
          # TODO What to do if widget is locked?
          e.preventDefault() if preventDefault
          e.stopPropagation() if stopPropagation
          self.emit(cls.TOUCH_MOVE_EVENT, [self._points(e)])

        touchEndFn = (e) ->
          # TODO What to do if widget is locked?
          e.preventDefault() if preventDefault
          e.stopPropagation() if stopPropagation
          self.element
            .unbind(events.TOUCH_MOVE_EVENT)
            .unbind(events.TOUCH_END_EVENT)
            .unbind(events.TOUCH_CANCEL_EVENT)
          self.emit(cls.TOUCH_END_EVENT, [self._points(e)])

        touchCancelFn = (e) ->
          # TODO What to do if widget is locked?
          e.preventDefault() if preventDefault
          e.stopPropagation() if stopPropagation
          self.element
            .unbind(events.TOUCH_MOVE_EVENT)
            .unbind(events.TOUCH_END_EVENT)
            .unbind(events.TOUCH_CANCEL_EVENT)
          self.emit(cls.TOUCH_CANCEL_EVENT, [self._points(e)])

        self.element
          .bind(events.TOUCH_START_EVENT, touchStartFn)

      ontouchstart: (e, point) ->

      ontouchmove: (e, point) ->

      ontouchend: (e, point) ->

      ontouchcancel: (e, point) ->

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

    exports.Touchable = Touchable
