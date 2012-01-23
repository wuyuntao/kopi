kopi.module("kopi.ui.zoomable")
  .require("kopi.ui.touchable")
  .define (exports, touchable) ->

    class Zoomable extends touchable.Touchable

    exports.Zoomable = Zoomable
