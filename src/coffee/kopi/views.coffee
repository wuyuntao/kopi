kopi.module("kopi.views")
  .require("kopi.settings")
  .require("kopi.utils")
  .require("kopi.utils.html")
  .require("kopi.widgets")
  .define (exports, settings, utils, html, widgets) ->

    ###
    View 的容器
    ###
    class ViewContainer extends widgets.Widget

      changeView: (view) ->

    ###
    View 的基类

    视图的载入应该越快越好，所以 AJAX 和数据库等 IO 操作不应该阻塞视图的显示
    ###
    class View extends widgets.Widget

      # type  #{Boolean}  created   视图是否已创建
      created: false
      # type  #{Boolean}  started   视图是否已启动
      started: false
      # type  #{Boolean}  started   视图是否允许操作
      locked: false

      constructor: (path, args=[]) ->
        throw new Error("Missing container") unless container?
        throw new Error("Missing path") unless path?

        this._id = utils.uniqueId(this.constructor.prefix)
        this._container = container
        this._path = path
        this._args = args

      
    class AsyncView extends View

      create: (callback) ->
        self = this
        failFn = -> throw new Error("Failed to create View: #{this.constructor.name}")
        failFn() if this.created or this.started
        doneFn = ->
          self.created = true
          callback(self)
        this._handlePromise(this.oncreate(), doneFn, failFn)
        this

      start: (view, callback) ->
        self = this
        failFn = -> throw new Error("Failed to start View: #{this.constructor.name}")
        failFn() if not this.created or this.started
        doneFn = ->
          self.started = true
          callback(self)
        this._handlePromise(this.onstart(), doneFn, failFn)
        this

      update: (callback) ->
        self = this
        failFn = -> throw new Error("Failed to update View: #{this.constructor.name}")
        failFn() if not this.created or not this.started
        doneFn = ->
          self.started = false
          callback(self)
        this._handlePromise(this.onupdate(), doneFn, failFn)

      ###
      ###
      stop: (view, callback) ->
        self = this
        failFn = -> throw new Error("Failed to stop View: #{this.constructor.name}")
        failFn() if not this.created or not this.started
        doneFn = ->
          self.started = false
          callback(self)
        this._handlePromise(this.onstop(), doneFn, failFn)

      destroy: (callback) ->
        self = this
        failFn = -> throw new Error("Failed to destroy View: #{this.constructor.name}")
        failFn() if this.created or this.started
        doneFn = ->
          self.created = false
          callback(self)
        this._handlePromise(this.ondestroy(), doneFn, failFn)

      lock: () ->
        return if this.locked
        # TODO 阻止 UI 操作
        this.locked = true
        this.onunlock()

      unlock: () ->
        return if not this.locked
        this.locked = false
        this.onlock()

      _handlePromise: (promise, doneFn, failFn) ->
        # This a async promise
        if utils.isPromise(promise)
          promise.done(doneFn).fail(failFn)

        # This a sync success result
        else if promise
          doneFn()

        # This a sync fail result
        else
          failFn()

        this

      ###
      事件的模板方法

      @param  {Function}    成功时的回调
      @return {Boolean|Promise}
      ###
      oncreate:  () -> true
      onstart:   () -> true
      onupdate:  () -> true
      onstop:    () -> true
      ondestroy: () -> true
      onlock:    () -> true
      onunlock:  () -> true

    exports.View = View
