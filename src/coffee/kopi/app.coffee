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
  viewport = require "kopi/ui/viewport"
  overlays = require "kopi/ui/notification/overlays"

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

    @START_EVENT = "start"
    @REQUEST_EVENT = "request"
    @VIEW_LOAD_EVENT = "viewload"
    @LOCK_EVENT = "lock"
    @UNLOCK_EVENT = "unlock"

    klass.configure this

    klass.accessor @prototype, "router"

    constructor: (options={}) ->
      # Make sure only one app is launched in current page
      throw new Error("Only one app can be initialized in current page") if appInstance
      # Set singleton of application
      appInstance = this

      self = this
      self.guid = utils.guid("app")
      self.started = false
      self.locked = false

      self.currentURL = null
      self.currentView = null

      self._views = {}
      self._interval = null
      self._router = null

      self.configure settings.kopi.app, options

    lock: ->
      self = this
      return self if self.locked
      cls = this.constructor
      overlays.show(transparent: true)
      self.emit(cls.LOCK_EVENT)

    unlock: ->
      self = this
      return self unless self.locked
      cls = this.constructor
      overlays.hide()
      self.emit(cls.UNLOCK_EVENT)

    onlock: ->
      this.locked = true

    onunlock: ->
      this.locked = false

    ###
    Launch the application

    ###
    start: ->
      cls = this.constructor
      self = this
      if self.started
        logger.warn("App has already been launched.")
        return self
      # Ensure layout elements
      self.container = $("body")
      self.viewport = viewport.instance()
      self.viewport.skeleton().render()
      self._listenToURLChange()
      self.emit(cls.START_EVENT)
      logger.info "Start app: #{self.guid}"
      self.started = true
      # Load current URL
      unless support.history and self._options.usePushState
        self.load(self._options.startURL or self.getCurrentURL())
      self

    stop: ->
      self = this
      self._stopListenToURLChange()
      self.started = false
      appInstance = null
      self

    getCurrentURL: ->
      url = uri.parse(location.href)
      uri.absolute((if url.fragment then url.fragment.substr(1) else ""), url.urlNoQuery)

    ###
    load URL

    @param {String} url   URL must be an absolute path without query string and fragment
    @param {Hash} options
    ###
    load: (url, options) ->
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
        self.once cls.VIEW_LOAD_EVENT, ->
          hist.pushState(null, null, state)
      else if self._options.useHashChange or self._options.useInterval
        # Set hash until view is loaded
        self.once cls.VIEW_LOAD_EVENT, ->
          loc.hash = uri.relative(url.urlNoQuery, baseURL)
      self.emit(cls.REQUEST_EVENT, [url, options])
      self

    ###
    callback when app receives new request

    @param {Event}  e
    @param {kopi.utils.uri.URI} url
    ###
    onrequest: (e, url, options) ->
      logger.info "Receive request: #{url.path}"
      self = this
      cls = this.constructor
      match = self._match(url)

      if not match
        logger.info "No matching view found."
        if self._options.redirectWhenNoRouteFound
          url = uri.unparse url
          logger.info("Redirect to URL: #{url}")
          uri.goto url
        return

      [view, request] = match

      isUpdate = false

      # If views are same, update the current view
      if self.currentView and self.currentView.equals(view)
        isUpdate = true
        self.currentView.update(request.url, request.params, options)
        return

      # If view is not created, create view then start
      view.create() unless view.created
      view.start(request.url, request.params, options)

      # If views are different, stop current view and start target view
      if not isUpdate and self.currentView and self.currentView.started
          self.currentView.stop(options)

      self.currentView = view
      self.currentURL = url
      self.emit(cls.VIEW_LOAD_EVENT)

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
      else if support.hash and (self._options.usePushState or self._options.useHashChange)
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

      if not self.currentURL or url.path != self.currentURL.path
        self.currentURL = url
        self.emit(cls.REQUEST_EVENT, [url])
      self

    ###
    Find existing view in stack

    @param  {kopi.utils.uri.URI} url
    @return {kopi.views.View}
    ###
    _match: (url) ->
      return logger.warn "Router is not provided" unless @_router

      self = this
      path = uri.parse(url).path
      request = @_router.match(path)

      # If no proper router is found
      return logger.warn("Can not find proper route for path: #{path}") unless request

      route = request.route
      for guid, view of self._views
        # If `group` is `true`, use same view for every URL matches route
        if route.group is true and view.name == route.view.name
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
      self._views[view.guid] = view
      [view, request]

  App: App
  instance: -> appInstance
