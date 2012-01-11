kopi.module("kopi.utils.events")
  .require("kopi.settings")
  .require("kopi.utils.support")
  .define (exports, settings, support) ->

    exports.MOUSE_OVER_EVENT = "mouseenter"
    exports.MOUSE_DOWN_EVENT = "mousedown"
    exports.MOUSE_MOVE_EVENT = "mousemove"
    exports.MOUSE_UP_EVENT = "mouseup"
    exports.MOUSE_OUT_EVENT = "mouseleave"

    exports.ORIENTATION_CHANGE_EVENT = "orientationchange"
    exports.THROTTLED_RESIZE_EVENT = "throttledresize"

    exports.LEFT_BUTTON = 1
    exports.MIDDLE_BUTTON = 2
    exports.RIGHT_BUTTON = 3

    if support.touch
      exports.TOUCH_START_EVENT = "touchstart"
      exports.TOUCH_MOVE_EVENT = "touchmove"
      exports.TOUCH_END_EVENT = "touchend"
      exports.TOUCH_CANCEL_EVENT = "touchcancel"
    else
      exports.TOUCH_START_EVENT = exports.MOUSE_DOWN_EVENT
      exports.TOUCH_MOVE_EVENT = exports.MOUSE_MOVE_EVENT
      exports.TOUCH_END_EVENT = exports.MOUSE_UP_EVENT
      exports.TOUCH_CANCEL_EVENT = exports.MOUSE_OUT_EVENT

    exports.WEBKIT_TRANSITION_END_EVENT = "webkitTransitionEnd"

    # TODO Check on mobile devices
    exports.isLeftClick = (event) ->
      event.which == exports.LEFT_BUTTON

    # TODO Check on mobile devices
    exports.isRightClick = (event) ->
      event.which == exports.RIGHT_BUTTON
