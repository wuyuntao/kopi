kopi.module("kopi.app.views")
  .require("kopi.exceptions")
  .require("kopi.settings")
  .require("kopi.events")
  .require("kopi.logging")
  .require("kopi.utils")
  .require("kopi.utils.html")
  .require("kopi.utils.text")
  .require("kopi.ui.panels")
  .define (exports, exceptions, settings, events, logging
                  , utils, html, text, panels) ->

    ###
    View 的基类

    视图的载入应该越快越好，所以 AJAX 和数据库等 IO 操作不应该阻塞视图的显示

    Example:

      class BookView
        header: new Nav(title: "Title")
        contentClass: ListContent
        footerFn: (view) ->

        onstart: ->
          Book.fetch (book) =>
            this.book = book
            super
    ###
    class View extends events.EventEmitter

      # utils.configure this
      #   eventTimeout: 60 * 1000     # 60 seconds

      # type  #{Boolean}  created   视图是否已创建
      created: false
      # type  #{Boolean}  started   视图是否已启动
      started: false
      # type  #{Boolean}  created   视图是否已初始化
      initialized: false
      # type  #{Boolean}  started   视图是否允许操作
      locked: false

      constructor: (app, args=[]) ->
        if not app
          throw new exceptions.ValueError("app must be instance of Application")
        self = this
        self.constructor.prefix or= text.underscore(self.constructor.name)
        self.guid = utils.guid(self.constructor.prefix)
        self.app = app
        self.args = args
        self.panels = app.layout.panels

      ###
      Initialize UI components skeleton and append them to DOM Tree
      ###
      create: (fn) ->
        self = this
        return self if self.created
        logging.debug("Create view. #{self.guid}")
        self.lock()
        self.on('created', (e) -> fn(false, self)) if $.isFunction(fn)
        self.emit('create')

      ###
      Display UI components and then render them with data
      ###
      start: (fn) ->
        self = this
        throw new exceptions.ValueError("Must create view first.") if not self.created
        return self if self.started
        logging.debug("Start view. #{self.guid}")
        self.lock()
        self.on('started', (e) -> fn(false, self)) if $.isFunction(fn)
        self.emit('start')

      ###
      Update UI components when URL changes
      ###
      update: (fn) ->
        self = this
        logging.debug("Update view. #{self.guid}")
        self.on('updated', (e) -> fn(false, this)) if $.isFunction(fn)
        self.emit('update')

      ###
      Hide UI components
      ###
      stop: (fn) ->
        self = this
        throw new exceptions.ValueError("Must create view first.") if not self.created
        return self if not self.started
        logging.debug("Stop view. #{self.guid}")
        self.lock()
        self.on('stopped', (e) -> fn(false, self)) if $.isFunction(fn)
        self.emit('stop')

      ###
      Remove UI components from DOM Tree
      ###
      destroy: (fn) ->
        self = this
        throw new exceptions.ValueError("Must stop view first.") if self.started
        return self if not self.created
        logging.debug("Destroy view. #{self.guid}")
        self.lock()
        self.on('destroyed', (e) -> fn(false, self)) if $.isFunction(fn)
        self.emit('destroy')

      lock: (fn) ->
        self = this
        return self if self.locked
        logging.debug("Lock view. #{self.guid}")
        self.locked = true
        self.emit 'lock'
        fn(false, self) if $.isFunction(fn)
        self

      unlock: (fn) ->
        self = this
        return self unless self.locked
        logging.debug("Unlock view. #{self.guid}")
        self.locked = false
        self.emit 'unlock'
        fn(false, self) if $.isFunction(fn)
        self

      ###
      事件的模板方法
      ###
      oncreate: (e) ->
        self = this
        # create contents and append them to panel asynchronously
        for name, panel of self.panels
          content = this._getContent(name, true)
          if content
            content.skeleton()
            panel.append(content)

        self.created = true
        self.unlock()
        logging.debug("View created. #{self.guid}")
        self.emit 'created'

      onstart: (e) ->
        self = this
        # Show contents asynchronously
        for name, panel of self.panels
          content = this._getContent(name)
          content.lock() if content
          panel.load(content)

        self.started = true
        self.unlock()
        if not self.initialized
          logging.debug("Initialize view. #{self.guid}")
          self.emit 'initialize'
        logging.debug("View started. #{self.guid}")
        self.emit 'started'

      oninitialize: (e) ->
        self = this
        # Initialize contents asynchronously
        for name, panel of self.panels
          panel = this._getContent(name)
          panel.render() if panel and not panel.rendered

        self.initialized = true
        logging.debug("View initialized. #{self.guid}")
        self.emit 'initialized'

      onupdate: (e) ->
        logging.debug("View updated. #{self.guid}")
        this.emit 'updated'

      onstop: (e) ->
        for name, panel of self.panels
          content = this._getContent(name)
          content.unlock() if content

        self = this
        self.started = false
        self.unlock()
        logging.debug("View stopped. #{self.guid}")
        self.emit 'stopped'

      ondestroy: (e) ->
        for name, panel of self.panels
          content = this._getContent(name)
          if content
            content.destroy()
            panel.remove(content)

        self = this
        self.created = false
        self.unlock()
        logging.debug("View destroyed. #{self.guid}")
        self.emit 'destroyed'

      ###
      Get panel if exists or create panel from template class or function
      ###
      _getContent: (name, create=true) ->
        return this[name] if name of this or not create
        contentClass = this[name + "Class"]
        return this[name] = new contentClass(this) if contentClass
        contentFn = this[name + "Fn"]
        return this[name] = contentFn(this) if contentFn

    exports.View = View
