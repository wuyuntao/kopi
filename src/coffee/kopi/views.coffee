define "kopi/views", (require, exports, module) ->

  exceptions = require "kopi/exceptions"
  klass = require "kopi/utils/klass"
  settings = require "kopi/settings"
  events = require "kopi/events"
  logging = require "kopi/logging"
  utils = require "kopi/utils"
  html = require "kopi/utils/html"
  text = require "kopi/utils/text"
  func = require "kopi/utils/func"

  logger = logging.logger(module.id)

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
    kls.START_EVENT = "start"
    kls.UPDATE_EVENT = "update"
    kls.STOP_EVENT = "stop"
    kls.DESTROY_EVENT = "destroy"
    kls.LOCK_EVENT = "lock"
    kls.UNLOCK_EVENT = "unlock"

    klass.accessor kls, "viewName",
      get: -> this._viewName or= this.name

    this.viewName "View"

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
    create: (options) ->
      cls = this.constructor
      self = this
      if self.created or self.locked
        logger.warn "View is already created or locked."
        return self
      logger.info("Create view. #{self.guid}")
      self.lock()
      self.emit(cls.CREATE_EVENT, [options])
      self.created = true
      self.unlock()

    ###
    Display UI components and then render them with data
    ###
    start: (url, params, options) ->
      cls = this.constructor
      self = this
      throw new exceptions.ValueError("Must create view first.") if not self.created
      if self.started or self.locked
        logger.warn "View is already started or locked."
        return self
      logger.info("Start view. #{self.guid}")
      self.lock()
      self.emit(cls.START_EVENT, [url, params, options])
      self.started = true
      self.unlock()

    ###
    Update UI components when URL changes
    ###
    update: (url, params, options) ->
      cls = this.constructor
      self = this
      if not self.started
        logger.error "Must start view first."
        return self
      if self.locked
        logger.warn "View is locked."
        return self
      logger.info("Update view. #{self.guid}")
      self.emit(cls.UPDATE_EVENT, [url, params, options])

    ###
    Hide UI components
    ###
    stop: (options) ->
      cls = this.constructor
      self = this
      throw new exceptions.ValueError("Must create view first.") if not self.created
      if not self.started or self.locked
        logger.warn "View is already stopped or locked."
        return self
      logger.info("Stop view. #{self.guid}")
      self.lock()
      self.emit(cls.STOP_EVENT, [options])
      self.started = false
      self.unlock()

    ###
    Remove UI components from DOM Tree
    ###
    destroy: (options) ->
      cls = this.constructor
      self = this
      throw new exceptions.ValueError("Must stop view first.") if self.started
      if not self.created or self.locked
        logger.warn "View is already destroyed or locked."
        return self
      logger.info("Destroy view. #{self.guid}")
      self.lock()
      self.emit(cls.DESTROY_EVENT, [options])
      self.created = false
      self.unlock()

    lock: ->
      cls = this.constructor
      self = this
      return self if self.locked
      logger.info("Lock view. #{self.guid}")
      self.locked = true
      self.emit cls.LOCK_EVENT
      self

    unlock: ->
      cls = this.constructor
      self = this
      return self unless self.locked
      logger.info("Unlock view. #{self.guid}")
      self.locked = false
      self.emit cls.UNLOCK_EVENT
      self

    ###
    Template methods of view events
    ###
    oncreate: (e) ->
    onstart: (e) ->
    onupdate: (e) ->
    onstop: (e) ->
    ondestroy: (e) ->
    onlock: (e) ->
    onunlock: (e) ->

    ###
    Helper methods
    ###
    equals: (view) ->
      this.guid == view.guid

  View: View
