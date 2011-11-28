kopi.module("kopi.ui.touchable")
  .require("kopi.utils.events")
  .require("kopi.ui.widgets")
  .define (exports, events, widgets) ->

    ###
    A widget supports touch events
    ###
    class Touchable extends widgets.Widget

      this.configure
        preventDefault: true
        stopPropagation: true
        multiTouch: false

      ondelegate: ->
        self = this
        preventDefault = self._options.preventDefault
        stopPropagation = self._options.stopPropagation

        touchStartFn = (e) ->
          return if self.locked
          e.preventDefault() if preventDefault
          e.stopPropagation() if stopPropagation
          self.emit(events.TOUCH_START_EVENT, [self._points(e)])
          self.element
            .on(events.TOUCH_MOVE_EVENT, touchMoveFn)
            .on(events.TOUCH_END_EVENT, touchEndFn)
            .on(events.TOUCH_CANCEL_EVENT, touchCancelFn)

        touchMoveFn = (e) ->
          # TODO What to do if widget is locked?
          e.preventDefault() if preventDefault
          e.stopPropagation() if stopPropagation
          self.emit(events.TOUCH_MOVE_EVENT, [self._points(e)])

        touchEndFn = (e) ->
          # TODO What to do if widget is locked?
          e.preventDefault() if preventDefault
          e.stopPropagation() if stopPropagation
          self.emit(events.TOUCH_END_EVENT, [self._points(e)])

        touchCancelFn = (e) ->
          # TODO What to do if widget is locked?
          e.preventDefault() if preventDefault
          e.stopPropagation() if stopPropagation
          self.emit(events.TOUCH_CANCEL_EVENT, [self._points(e)])

        self.element
          .on(events.TOUCH_START_EVENT, touchStartFn)

      ontouchstart: (e, event) ->

      ontouchmove: (e, event) ->

      ontouchend: (e, event) ->

      ontouchcancel: (e, event) ->

      ###
      Get point from event
      ###
      _points: (event) ->
        event = event.originalEvent
        if support.touch
          if this._options.multiTouch then event.touches else event.touches[0]
        else
          if this._options.multiTouch then [event] else event

    exports.Touchable = Touchable
