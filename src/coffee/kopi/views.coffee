define "kopi/views", (require, exports, module) ->

  exceptions = require "kopi/exceptions"
  klass = require "kopi/utils/klass"
  settings = require "kopi/settings"
  events = require "kopi/events"
  logging = require "kopi/logging"
  utils = require "kopi/utils"
  html = require "kopi/utils/html"
  text = require "kopi/utils/text"

  ###
  Base class of views

  Life cycle of a view:

  Constructor -> Create -> Start (-> Update) -> Stop -> Destroy (-> Create -> ...)


  Example:

    class SomeView

      oncreate: ->
        this.nav = new SomeNav()
        this.content = new SomeContent()
        this.footer = new SomeTabs()

      onstart: ->
        this.nav.skeleton().render()
        this.content.skeleton().render()
        this.footer.skeleton().render()

        this.app.navBar.load(this.nav)
        this.app.viewFlipper.load(this.content)
        this.app.tabBar.load(this.footer)

      onstop: ->
        this.nav.destroy()
        this.content.destroy()
        this.footer.destroy()

      ondestroy: ->
        this.nav = null
        this.content = null
        this.footer = null

  ###
  class View extends events.EventEmitter

    kls = this
    kls.CREATE_EVENT = "create"
    kls.CREATED_EVENT = "created"
    kls.START_EVENT = "start"
    kls.STARTED_EVENT = "started"
    kls.UPDATE_EVENT = "update"
    kls.UPDATED_EVENT = "updated"
    kls.STOP_EVENT = "stop"
    kls.STOPPED_EVENT = "stopped"
    kls.DESTROY_EVENT = "destroy"
    kls.DESTROYED_EVENT = "destroyed"
    kls.LOCK_EVENT = "lock"
    kls.UNLOCK_EVENT = "unlock"

    klass.accessor kls, "viewName",
      get: -> this._viewName or= this.name

    constructor: (app, url, params={}) ->
      if not app
        throw new exceptions.ValueError("app must be instance of Application")
      self = this
      self.constructor.prefix or= text.dasherize(self.constructor.viewName())
      self.guid = utils.guid(self.constructor.prefix)
      self.app = app
      self.url = url
      self.params = params

      # type  #{Boolean}  created   Is the view is created?
      self.created = false
      # type  #{Boolean}  started   Is the view is started?
      self.started = false
      # type  #{Boolean}  locked    Is the view is locked?
      self.locked = false

    ###
    Initialize UI components skeleton and append them to DOM Tree
    ###
    create: (fn) ->
      cls = this.constructor
      self = this
      if self.created or self.locked
        logger.warn "View is already created or locked."
        return self
      logging.info("Create view. #{self.guid}")
      self.lock()
      self.on(cls.CREATED_EVENT, (e) -> fn(false, self)) if fn
      self.emit(cls.CREATE_EVENT)

    ###
    Display UI components and then render them with data
    ###
    start: (url, params, fn) ->
      cls = this.constructor
      self = this
      throw new exceptions.ValueError("Must create view first.") if not self.created
      if self.started or self.locked
        logger.warn "View is already started or locked."
        return self
      logging.info("Start view. #{self.guid}")
      self.lock()
      self.on(cls.STARTED_EVENT, (e) -> fn(false, self)) if fn
      self.emit(cls.START_EVENT)

    ###
    Update UI components when URL changes
    ###
    update: (url, params, fn) ->
      cls = this.constructor
      self = this
      if not self.started
        throw new exceptions.ValueError("Must start view first.")
      if self.locked
        logger.warn "View is locked."
        return self
      logging.info("Update view. #{self.guid}")
      self.on(cls.UPDATED_EVENT, (e) -> fn(false, this)) if fn
      self.emit(cls.UPDATE_EVENT)

    ###
    Hide UI components
    ###
    stop: (fn) ->
      cls = this.constructor
      self = this
      throw new exceptions.ValueError("Must create view first.") if not self.created
      if not self.started or self.locked
        logger.warn "View is already stopped or locked."
        return self
      logging.info("Stop view. #{self.guid}")
      self.lock()
      self.on(cls.STOPPED_EVENT, (e) -> fn(false, self)) if fn
      self.emit(cls.STOP_EVENT)

    ###
    Remove UI components from DOM Tree
    ###
    destroy: (fn) ->
      cls = this.constructor
      self = this
      throw new exceptions.ValueError("Must stop view first.") if self.started
      if not self.created or self.locked
        logger.warn "View is already destroyed or locked."
        return self
      logging.info("Destroy view. #{self.guid}")
      self.lock()
      self.on(cls.DESTROYED_EVENT, (e) -> fn(false, self)) if fn
      self.emit(cls.DESTROY_EVENT)

    lock: (fn) ->
      cls = this.constructor
      self = this
      return self if self.locked
      logging.info("Lock view. #{self.guid}")
      self.locked = true
      self.emit cls.LOCK_EVENT
      fn(false, self) if fn
      self

    unlock: (fn) ->
      cls = this.constructor
      self = this
      return self unless self.locked
      logging.info("Unlock view. #{self.guid}")
      self.locked = false
      self.emit cls.UNLOCK_EVENT
      fn(false, self) if fn
      self

    ###
    Template methods of view events
    ###
    oncreate: (e) ->
      cls = this.constructor
      self = this
      self.created = true
      self.unlock()
      logging.info("View created. #{self.guid}")
      self.emit cls.CREATED_EVENT

    onstart: (e) ->
      cls = this.constructor
      self = this
      self.started = true
      self.unlock()
      logging.info("View started. #{self.guid}")
      self.emit cls.STARTED_EVENT

    onupdate: (e) ->
      cls = this.constructor
      self = this
      logging.info("View updated. #{self.guid}")
      self.emit cls.UPDATED_EVENT

    onstop: (e) ->
      cls = this.constructor
      self = this
      self.started = false
      self.unlock()
      logging.info("View stopped. #{self.guid}")
      self.emit cls.STOPPED_EVENT

    ondestroy: (e) ->
      cls = this.constructor
      self = this
      self.created = false
      self.unlock()
      logging.info("View destroyed. #{self.guid}")
      self.emit cls.DESTROYED_EVENT

    onlock: (e) ->

    onunlock: (e) ->

    ###
    Helper methods
    ###
    equals: (view) ->
      this.guid == view.guid

  View: View
