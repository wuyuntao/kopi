kopi.module("kopi.views")
  .define (exports) ->
    ###
    View 的基类

    ###
    class View

      created: false
      started: false

      constructor: (container, path, args=[]) ->
        throw new Error("Missing container") unless container?
        throw new Error("Missing path") unless path?
        this.container = container
        this.path = path
        this.args = args

      create: (callback) ->
        this.created = true
        callback(this)

      start: (callback) ->
        this.started = true
        callback(this)

      stop: (callback) ->
        this.started = false
        callback(this)

      destroy: (callback) ->
        this.created = false
        callback(this)

    exports.View = View
