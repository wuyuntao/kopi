kopi.module("kopi.views")
  .require("kopi.utils")
  .require("kopi.events")
  .define (exports, utils, events) ->
    ###
    View 的基类

    ###
    class View extends events.EventEmitter

      # type  #{Boolean}  created   视图是否已创建
      created: false
      # type  #{Boolean}  started   视图是否已启动
      started: false

      constructor: (container, path, args=[]) ->
        throw new Error("Missing container") unless container?
        throw new Error("Missing path") unless path?
        super()
        this.container = container
        this.path = path
        this.args = args

      create: (callback) ->
        self = this
        failFn = -> throw new Error("Failed to create View: #{this.constructor.name}")
        failFn() if this.created or this.started
        doneFn = ->
          self.created = true
          callback(self)
        this._handlePromise(this.oncreate(), doneFn, failFn)
        this

      start: (callback) ->
        self = this
        failFn = -> throw new Error("Failed to start View: #{this.constructor.name}")
        failFn() if not this.created or this.started
        doneFn = ->
          self.started = true
          callback(self)
        this._handlePromise(this.onstart(), doneFn, failFn)
        this

      stop: (callback) ->
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
        this._handlePromise(this.onstop(), doneFn, failFn)

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
      模板方法

      @param  {Function}    成功时的回调
      @return {
      ###
      oncreate:  () -> true
      onstart:   () -> true
      onstop:    () -> true
      ondestroy: () -> true

    exports.View = View
