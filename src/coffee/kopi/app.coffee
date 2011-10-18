kopi.module("kopi.app")
  .require("kopi.exceptions")
  .require("kopi.settings")
  .require("kopi.app.cache")
  .require("kopi.app.router")
  .require("kopi.utils.support")
  .require("kopi.ui.viewport")
  .require("kopi.ui.navigation")
  .require("kopi.ui.views")
  .define (exports, exceptions, settings, cache, router, support
                  , viewport, navigation, views) ->

    win = $(window)

    ###
    核心应用，负责管理应用的启动，设置
    ###
    class Application

      started: false

      state: null

      # @type {Boolean}       If able to change state
      locked: false

      # @type {Hash<URL, State>}
      stack: {}

      constructor: ->
        self = this
        self.cache = cache
        self.router = router

        # Ensure layout elements
        $ ->
          self.viewport = new viewport.Viewport(settings.kopi.ui.viewport)
          self.navbar = new navigation.Navbar(settings.kopi.ui.navbar)
          self.container = new views.ViewContainer(settings.kopi.ui.container)

      start: (options={}) ->
        return this if this.started

        if support.history
          win.bind 'popstate', this.check
        else if support.hash
          throw new exceptions.NotImplementedError()
          # win.bind 'hashchange', this.check
        else
          throw new exceptions.NotImplementedError()
          # setInterval settings.kopi.app.interval, this.check

      ###
      See if state has been changed
      ###
      check: (e) ->
        return false if this.locked
        current = this.getCurrent()
        return false if state == current
        this.load(current)

      load: (state) ->
        match = this.router.matches(state)
        if match
          view = new match.route.view(match.args...)
          # Update navbar
          # TODO Should be async methods
          # TODO Generate nav on fly
          if view.navbar
            self.navbar.load(navbar)
          else
            self.navbar.hide()
          # Update contaienr
          self.container.load(view)

      getCurrentState: ->
        location.pathname

    app = null

    start = (callback) ->
      if not app
        app = new Application()
        app.start()
        callback() if $.isFunction(callback)

    exports.start = start
