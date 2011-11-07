kopi.module("kopi.app")
  .require("kopi.exceptions")
  .require("kopi.settings")
  .require("kopi.app.cache")
  .require("kopi.app.router")
  .require("kopi.app.views")
  .require("kopi.tasks")
  .require("kopi.utils.support")
  .require("kopi.utils.uri")
  .require("kopi.ui.viewport")
  .require("kopi.ui.navigation")
  .require("kopi.ui.layouts")
  .require("kopi.ui.notification")
  .define (exports, exceptions, settings, cache, router, views, tasks, support, uri
                  , viewport, navigation, layouts, notification) ->

    win = $(window)

    ###
    核心应用，负责管理应用的启动，设置
    ###
    class Application

      constructor: ->
        this.started = false
        this.locked = false
        this.currentView = null
        # @type {Hash<URL, State>}
        this._viewStack = {}

      start: () ->
        return this if this.started
        self = this
        self.taskQueue = new tasks.Queue()
        self.taskWorker = new tasks.Worker(self.taskQueue)
        $ ->
          # Ensure layout elements
          self.viewport = new viewport.Viewport(settings.kopi.ui.viewport)
          # Build layout
          self.layout or= layouts.default()
          # Load current URL
          self.load uri.current()

          # if support.history
          #   win.bind 'popstate', this.onpopstate
          # else if support.hash
          #   throw new exceptions.NotImplementedError()
          #   # win.bind 'hashchange', this.check
          # else
          #   throw new exceptions.NotImplementedError()
          #   # setInterval settings.kopi.app.interval, this.check

      ###
      See if state has been changed
      ###
      check: (e) ->
        # TODO Add to queue if locked
        return false if this.locked

        current = this.getCurrent()
        return false if state == current
        this.load(current)

      load: (url) ->
        self = this
        path = uri.parse(url).path
        # Find started view
        view = self.match(path)
        unless view
          # Find view matches
          match = router.match(path)
          unless match
            return uri.goto url
          view = new match.route.view(self, match.args)

        # Stop current view
        if self.current and self.current.started
          self.current.stop()
        # Start view
        if not view.created
          view.create()
        view.start()

      ###
      Find existing view in stack
      ###
      match: (url) ->
        view = this._stack[url]
        return view if view and view.created

    app = null

    start = (callback) ->
      if not app
        app = new Application()
        app.start()
        callback() if $.isFunction(callback)

    exports.start = start
