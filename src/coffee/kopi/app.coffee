kopi.module("kopi.app")
  .require("kopi.exceptions")
  .require("kopi.settings")
  .require("kopi.app.state")
  .require("kopi.ui.viewport")
  .define (exports, exceptions, settings, state, viewport) ->

    ###
    核心应用，负责管理应用的启动，设置
    ###
    class Application

      constructor: ->

        # Initialize state manager
        this.manager = new state.Manager()

        # Ensure layout elements
        this.viewport = new viewport.Viewport(settings.kopi.ui.viewport)

      start: ->


    app = null

    start = (callback) ->
      if not app
        app = new Application()
        app.start()
        callback() if $.isFunction(callback)

    exports.start = start
