kopi.module("kopi.app.views")
  .require("kopi.exceptions")
  .require("kopi.settings")
  .require("kopi.events")
  .require("kopi.utils")
  .require("kopi.utils.html")
  .require("kopi.utils.text")
  .require("kopi.ui.contents")
  .define (exports, exceptions, settings, events
                  , utils, html, text, contents) ->

    ###
    View 的基类

    视图的载入应该越快越好，所以 AJAX 和数据库等 IO 操作不应该阻塞视图的显示
    ###
    class View extends events.EventEmitter

      ###
      @type {Hash <String, Content>}
      ###
      this._contents = {}

      ###
      Extend contents
      ###
      this.contents = (contents={}) ->
        utils.extend this._contents, contents

      this.defaults
        eventTimeout: 60 * 1000     # 60 seconds

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
        self.uid = utils.uniqueId(self.constructor.prefix)
        self.app = app
        self.contents = {}
        self.containers = app.layout.containers
        self.request, self.args... = args

      create: ->
        self = this
        return self if self.created
        self.lock()
        self.emit 'create'

      start: ->
        self = this
        throw new exceptions.ValueError("Must create view first.") if not self.created
        return self if self.started
        self.lock()
        self.emit 'start'

      update: ->
        this.emit('update')

      stop: ->
        self = this
        throw new exceptions.ValueError("Must create view first.") if not self.created
        return self if not self.started
        self.lock()
        self.emit 'stop'

      destroy: ->
        self = this
        throw new exceptions.ValueError("Must stop view first.") if self.started
        return self if not self.created
        self.lock()
        self.emit 'destroy'

      ###
      事件的模板方法

      @param  {Function}    成功时的回调
      @return {Boolean|Promise}
      ###
      oncreate: (e) ->
        self = this
        # create contents and append them to container asynchronously
        for name, container of self.containers
          if name of self.constructor._contents
            content = self.contents[name] = new content(self)
            self.containers.append(content)

        self.created = true
        self.unlock()
        self.emit 'created'

      onstart: (e) ->
        self = this
        # Show contents asynchronously
        for name, container of self.containers
          if name of self.contents
            self.containers.load(self.contents[name])
          else
            self.containers.hide()

        self.started = true
        self.unlock()
        self.emit 'initialize' if not self.initialized
        self.emit 'started'

      oninitialize: (e) ->
        self = this
        # Initialize contents asynchronously
        for name, container of self.containers
          if name of self.contents
            self.contents[name].initialize()

        self.initialized = true
        self.emit 'initialized'

      onupdate: (e) ->
        this.emit 'updated'

      onstop: (e) ->
        self = this
        self.started = false
        self.unlock()
        self.emit 'stopped'

      ondestroy: (e) ->
        self = this
        self.created = false
        self.unlock()
        self.emit 'destroyed'

    exports.View = View
