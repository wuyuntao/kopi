define "kopi/app", (require, exports, module) ->

  $ = require "jquery"
  settings = require "kopi/settings"
  logging = require "kopi/logging"
  events = require "kopi/events"
  utils = require "kopi/utils"
  uri = require "kopi/utils/uri"
  support = require "kopi/utils/support"
  text = require "kopi/utils/text"
  array = require "kopi/utils/array"
  klass = require "kopi/utils/klass"
  router = require "kopi/app/router"
  viewport = require "kopi/ui/viewport"

  win = $(window)
  hist = history
  loc = location
  baseURL = uri.current()
  logger = logging.logger(module.id)
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

    klass.configure kls

    constructor: (options={}) ->
      self = this
      self.guid = utils.guid("app")
      self.started = false
      self.locked = false

      self.currentURL = null
      self.currentView = null

      self._views = []
      self._interval = null

      self.configure settings.kopi.app, options

    ###
    Launch the application

    ###
    start: (fn) ->
      cls = this.constructor
      self = this
      if self.started
        logger.warn("App has already been launched.")
        return self
      # Make sure only one app is launched in current page
      if appInstance and appInstance.guid != self.guid
        logger.error("Only one app can be launched in current page")
        return self
      # Set singleton of application
      appInstance = self
      # Ensure layout elements
      self.container = $("body")
      self.viewport = viewport.instance()
      self.viewport.skeleton().render()
      self.emit(cls.START_EVENT)
      self._listenToURLChange()
      # Load current URL
      self.load(self._options.startURL or self.getCurrentURL())
      self.started = true
      fn() if fn
      self

    stop: (fn) ->
      self = this
      self._stopListenToURLChange()
      self.started = false
      appInstance = null
      fn() if fn
      self

    getCurrentURL: ->
      url = uri.parse(location.href)
      uri.absolute((if url.fragment then url.fragment.substr(1) else ""), url.urlNoQuery)

    ###
    load URL

    @param {String} url   URL must be an absolute path without query string and fragment
    ###
    load: (url) ->
      logger.info "Load URL: #{url}"
      cls = this.constructor
      self = this
      url = uri.parse uri.absolute(url)
      # When using hash, absolute URLs will be converted to relative hashes.
      # e.g.
      #   If baseURI is /foo and absolute URL is /foo/bar
      #   The request url will be /foo#/bar
      if support.history and self._options.usePushState
        if self._options.alwaysUseHash
          state = "#" + uri.relative(url.urlNoQuery, baseURL)
        else
          state = url.path
        hist.pushState(null, null, state)
        self.emit(cls.REQUEST_EVENT, [url])
      else if self._options.useHashChange or self._options.useInterval
        loc.hash = uri.relative(url.urlNoQuery, baseURL)
      self

    ###
    callback when app starts

    ###
    onstart: (e) ->
      logger.info "Start app: #{this.guid}"

    ###
    callback when app receives new request

    @param {Event}  e
    @param {kopi.utils.uri.URI} url
    ###
    onrequest: (e, url) ->
      logger.info "Receive request: #{url.path}"
      self = this
      match = self._match(url)

      if not match
        if self._options.redirectWhenNoRouteFound
          url = uri.unparse url
          logger.info("Redirect to URL: #{url}")
          uri.goto url
        return

      [view, request] = match

      # If views are same, update the current view
      # TODO Add to some method. e.g. view.equals(self.currentView)
      if self.currentView and view.guid == self.currentView.guid
        self.currentView.update(request.url, request.params)
        return

      # If views are different, stop current view and start target view
      if self.currentView and self.currentView.started
        self.currentView.stop()
      # If view is not created, create view then start
      if not view.created
        view.create -> view.start(request.url, request.params)
      else
        view.start(request.url, request.params)
      self.currentView = view

    ###
    Listen to URL change events.
    For HTML5 browsers, listen to `onpopstate` event by default.
    For HTML4 browsers, listen to `onhashchange` event by default.
    For Legacy browsers, check url change by interval.

    ###
    _listenToURLChange: ->
      self = this
      checkFn = -> self._checkURLChange()
      if support.history and self._options.usePushState
        self._useHash = self._options.alwaysUseHash
        win.bind 'popstate', checkFn
      else if support.hash and self._options.useHashChange
        self._useHash = true
        win.bind "hashchange", checkFn
      else if self._options.useInterval
        self._useHash = true
        self._interval = setInterval checkFn, self._options.interval
      else
        logger.warn("App will not repond to url change")
      return

    ###
    Listen to URL change events.
    For HTML5 browsers, stop listen to `onpopstate` event by default.
    For HTML4 browsers, stop listen listen to `onhashchange` event by default.
    For Legacy browsers, stop listen check url change by interval.

    ###
    _stopListenToURLChange: ->
      self = this
      checkFn = -> self._checkURLChange()
      if support.history and self._options.usePushState
        win.unbind 'popstate'
      else if support.hash and self._options.useHashChange
        win.unbind "hashchange"
      else if self._options.useInterval
        if self._interval
          clearInterval(self._interval)
          self._interval = null
      return

    ###
    Check if URL is different from last state
    ###
    _checkURLChange: ->
      cls = this.constructor
      self = this
      url = uri.parse(location.href)
      if self._useHash
        # Combine path and hash
        url.path = uri.absolute(url.fragment.replace(/^#/, ''), url.path)

      # if not self.currentURL or url.path != self.currentURL.path
      #   self.currentURL = url
      #   self.emit(cls.REQUEST_EVENT, [url])
      self

    ###
    Find existing view in stack

    @param  {kopi.utils.uri.URI} url
    @return {kopi.views.View}
    ###
    _match: (url) ->
      self = this
      path = uri.parse(url).path
      request = router.match(path)

      # If no proper router is found
      if not request
        logger.warn("Can not find proper route for path: #{path}")
        return

      route = request.route
      for view in self._views
        # If `group` is `true`, use same view for every URL matches route
        if route.group is true
          if view.name == route.view.name
            return [view, request]
        # If `group` is `string`, use same view for every URL matches route
        else if text.isString(route.group)
          if view.params[route.group] == route.params[route.group]
            return [view, request]
        # If `group` is `array`, use same view for every URL matches route
        else if array.isArray(route.group)
          matches = true
          for param in route.group
            if view.params[param] != route.params[param]
              matches = false
              break
          if matches
            return [view, request]
        # If `group` is false, use different view for different URLs
        else
          if view.url.path == path
            return [view, request]

      # Create view and add it to list
      view = new route.view(self, request.url, request.params)
      self._views.push(view)
      [view, request]

  App: App
  instance: -> appInstance
