kopi.module("kopi.ui.clickable")
  .require("kopi.ui.touchable")
  .define (exports, touchable) ->

    ###
    A base widget responsive to click, hold, hover and other button-like behaviors
    ###
    class Clickable extends touchable.Touchable

      kls = this
      kls.HOVER_EVENT = "hover"
      kls.CLICK_EVENT = "click"
      kls.TAP_HOLD_EVENT = "taphold"

      kls.configure
        # @param  {Boolean} if responsive to mouse hover event
        hoverable: true
        # @param  {Boolean} if responsive to click event
        clickable: true
        # @param  {Boolean} if responsive to tap and hold event
        tapHoldable: true
        classPrefix: null

      constructor: ->
        super

    exports.Clickable = Clickable
