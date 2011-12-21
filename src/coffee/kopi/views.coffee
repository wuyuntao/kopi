kopi.module("kopi.views")
  .require("kopi.exceptions")
  .require("kopi.settings")
  .require("kopi.events")
  .require("kopi.logging")
  .require("kopi.utils")
  .require("kopi.utils.html")
  .require("kopi.utils.text")
  .define (exports, exceptions, settings, events, logging
                  , utils, html, text) ->

    ###
    View 的基类

    视图的载入应该越快越好，所以 AJAX 和数据库等 IO 操作不应该阻塞视图的显示

    Life cycle:

    Constructor -> Create -> Start -> Update -> Stop -> Destroy


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

      constructor: (app, url, params={}) ->
        if not app
          throw new exceptions.ValueError("app must be instance of Application")
        self = this
        self.constructor.prefix or= text.underscore(self.constructor.name)
        self.guid = utils.guid(self.constructor.prefix)
        self.app = app
        self.url = url
        self.params = params

        # type  #{Boolean}  created   视图是否已创建
        self.created = false
        # type  #{Boolean}  started   视图是否已启动
        self.started = false
        # type  #{Boolean}  started   视图是否允许操作
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
      事件的模板方法
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

    exports.View = View
