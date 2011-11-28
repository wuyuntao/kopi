kopi.module("kopi.utils.events")
  .require("kopi.settings")
  .require("kopi.utils.support")
  .define (exports, settings, support) ->

    ###
    Extend jQuery events for mobile devices
    ###
    ORIENTATION_CHANGE_EVENT = "orientationchange"
    THROTTLED_RESIZE_EVENT = "throttledresize"

    if support.touch
      TOUCH_START_EVENT = "touchstart"
      TOUCH_MOVE_EVENT = "touchmove"
      TOUCH_END_EVENT = "touchend"
    else
      TOUCH_START_EVENT = "mousedown"
      TOUCH_MOVE_EVENT = "mousemove"
      TOUCH_END_EVENT = "mouseup"

    TAP_EVENT = "tap"
    TAP_HOLD_EVENT = "taphold"
    SWIPE_EVENT = "swipe"
    SWIPE_LEFT_EVENT = "swipeleft"
    SWIPE_RIGHT_EVENT = "swiperight"

    exports.ORIENTATION_CHANGE_EVENT = ORIENTATION_CHANGE_EVENT
    exports.THROTTLED_RESIZE_EVENT = THROTTLED_RESIZE_EVENT
    exports.TOUCH_START_EVENT = TOUCH_START_EVENT
    exports.TOUCH_MOVE_EVENT = TOUCH_MOVE_EVENT
    exports.TOUCH_END_EVENT = TOUCH_END_EVENT
    exports.TAP_EVENT = TAP_EVENT
    exports.TAP_HOLD_EVENT = TAP_HOLD_EVENT
    exports.SWIPE_EVENT = SWIPE_EVENT
    exports.SWIPE_LEFT_EVENT = SWIPE_LEFT_EVENT
    exports.SWIPE_RIGHT_EVENT = SWIPE_RIGHT_EVENT
