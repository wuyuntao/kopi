define "kopi/events", (require, exports, module) ->

  $ = require "jquery"

  ###
  用 jQuery Events API 实现的类 NodeJS 事件机制

  TODO Use EventEmitter of NodeJS?

  EventEmitter.on tests, 'done', -> alert('all tests done')

  ###
  class EventEmitter

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
      this._emitter.triggerHandler(arguments...)
      this

    once: ->
      this._emitter or= $(this)
      this._emitter.one(arguments...)
      this

  EventEmitter: EventEmitter
