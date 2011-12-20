kopi.module("kopi.app")
  .require("kopi.settings")
  .require("kopi.logging")
  .require("kopi.events")
  .require("kopi.utils.uri")
  .require("kopi.utils.support")
  .require("kopi.app.cache")
  .require("kopi.app.router")
  .require("kopi.ui.viewport")
  .define (exports, settings, logging, events
                  , uri, support
                  , cache, router, viewport) ->

    win = $(window)
    hist = history
    loc = location
    logger = logging.logger(exports.name)
    appSettings = settings.kopi.app
    appInstance = null

    ###
    Application class

    Usage

    class BookApp extends App

      onstart: ->
        super
        # Do stuff when app starts
        self = this
        self.bookNavBar = new BookNavBar()
        self.bookViewer = new BookViewer()
        self.taskQueue = new TaskQueue()
        self.taskWorker = new TaskWorker(self.taskQueue)

      onrequest: (e, url) ->
        if url.match(/^\/books$/)
          # Do stuff when url matches /books
        else if url.match(/^\/books/\d+$/)
          # Do stuff when url matches /books/1
        super

    $ ->
      new BookApp().start()

    ###
    class App extends events.EventEmitter

      kls = this
      kls.START_EVENT = "start"
      kls.REQUEST_EVENT = "request"

      constructor: ->
        self = this
        self.started = false
        self.locked = false

        self._currentURL = null
        self._currentView = null
        self._views = []

      start: ->
        cls = this.constructor
        self = this
        if self.started
          logger.warn("App has already been launched.")
          return self
        # Make sure only one app is launched in current page
        if appInstance
          logger.error("Only one app can be launched in current page")
          return self
        # Set singleton of application
        appInstance = self
        # Ensure layout elements
        self.viewport = new viewport.Viewport()
        self.emit(kls.START_EVENT)
        # Load current URL
        self.load(appSettings.startURL or uri.current())
        self._listenToStateChange()
        self

      load: (url) ->
        self = this
        self.url(url)

      ###
      Convert url to state

      @param {String} url
      ###
      _parse: (url) ->
        # url = uri.current() if not url
        if support.pushState and appSettings.usePushState
          #
        else
          #

      _listenToURLChange: ->
        cls = this.constructor
        self = this
        if support.pushState and appSettings.usePushState
          $(hist).bind 'popstate', (e) ->
            self.emit(cls.REQUEST_EVENT, [url])
        else if support.hashChange and appSettings.useHashChange
          win.bind "hashchange",
        else if appSettings.useInterval
          #
        else
          logger.warn("App will not repond to url change")
        return

      ###
      ###
      url: (url) ->
        cls = this.constructor
        self = this
        url = uri.absolute(url)
        if support.pushState and appSettings.usePushState
          hist.pushState(url)
          self.emit(cls.REQUEST_EVENT, [url])
        else
          loc.hash = url
        self

      ###
      See if state has been changed
      ###
      check: (e) ->
        # TODO Add to queue if locked
        return false if this.locked

        current = this.getCurrent()
        return false if state == current
        this.load(current)

      onstart: (e) ->

      onrequest: (e, url) ->
        self = this
        view = self._match(url)
        if self._currentView and self._currentView.started
          self._currentView.stop()
        if not view.created
          view.create ->
            view.start()
        else
          view.start()

      ###
      Find existing view in stack
      ###
      _match: (url) ->
        path = uri.parse(url).path
        request = router.match(path)

        # If no proper router is found
        if not request
          logger.warn("Can not find proper route for path: #{path}")
          if appSettings.redirectWhenNoRouteFound
            logger.info("Redirect to URL: #{url}")
            uri.goto url
          return

        route = request.route
        # Find route in existing views
        # If `group` is `true`, use same view for every URL matches route
        # if route.group is true
        #   viewKey = "view:#{route.view.name}"
        # If `group` is `false` or not defined, use unique key for different URLs
        # else if not route.group
        #   pathKey = "path:#{path}"
        # else if text.isString(route.group)
        #   arg = route.group
        #   if arg not in route.args
        #     logger.warn("Can not find argument: #{arg}")
        #   argsKey = "args:#{arg}:#{route.args[arg]}"
        # else if array.isArray(route.group)
        #   args = []
        #   for arg in route.group
        #     if arg not in route.args
        #       logger.warn("Can not find argument: #{arg}")
        #       continue
        #     args.push("#{arg}:#{route.args[arg]}")
        #   argsKey = "args:#{args.join(':')}"
        # logger.debug "Got key for view. #{key}"
        key = null # Find key for view
        view = null # Find view by key

        # Create view and add it to list if neccessary
        if not view
          view = new route.view(self, request.url, request.params)
          self._views.push(view)
        view

        ###
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

    exports.App = App
    exports.instance = -> appInstance
