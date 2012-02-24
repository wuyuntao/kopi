define "kopi/events", (require, exports, module) ->

  $ = require "jquery"

  ###
  A Node-style event emitter implemented via jQuery's Event API

  TODO Use EventEmitter of NodeJS?
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
