kopi.module("kopi.events")
  .define (exports) ->

    ###
    用 jQuery Events API 实现的类 NodeJS 事件机制

    ###
    class EventEmitter
      constructor: ->
        this._emitter = $(this)

      on: ->
        this._emitter or= $(this)
        this._emitter.bind(arguments...)
        this

      off: ->
        this._emitter or= $(this)
        this._emitter.unbind(arguments...)
        this

      emit: ->
        this._emitter or= $(this)
        this._emitter.trigger(arguments...)
        this

      once: ->
        this._emitter or= $(this)
        this._emitter.one(arguments...)

    exports.EventEmitter = EventEmitter
