kopi.module("kopi.app")
  .require("kopi.settings")
  .define (exports, settings) ->

    ###
    核心应用，负责管理应用的启动，设置
    ###
    class Application

      constructor: ->

      start: ->

    app = null

    start = ->
      if not app
        app = new Application()
        app.start()

    exports.start = start
