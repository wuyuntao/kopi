define "kopi/ui/startup", (require, exports, module) ->

  $ = require "jquery"
  widgets = require "kopi/ui/widgets"

  class SplashScreen extends widgets.Widget

    onskeleton: ->
      $(this.element).bind "click", (e) -> return false
      super

  SplashScreen: SplashScreen
