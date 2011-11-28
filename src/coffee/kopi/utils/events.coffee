kopi.module("kopi.utils.events")
  .require("kopi.utils.support")
  .define (exports) ->

    exports.TOUCH_START_EVENT = "touchstart"
    exports.TOUCH_MOVE_EVENT = "touchmove"
    exports.TOUCH_END_EVENT = "touchend"
