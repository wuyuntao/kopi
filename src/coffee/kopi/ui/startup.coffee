kopi.module("kopi.ui.startup")
  .require("kopi.ui.widgets")
  .define (exports, widgets) ->

    class SplashScreen extends widgets.Widget

      onskeleton: ->
        $(this.element).bind "click", (e) -> return false
        super

    exports.SplashScreen = SplashScreen
