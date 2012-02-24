define "kopi/clients", (require, exports, module) ->

  exceptions = require "kopi/exceptions"
  settings = require "kopi/settings"

  class ClientNotSupported extends exceptions.Exception

  clients = {}

  ###
  Enable client for adapter
  ###
  register = (platform, client) ->
    if client
      clients[platform] = new client()
    module.exports

  ###
  Disable client for adapter
  ###
  unregister = (platform) ->
    delete clients[platform]
    module.exports

  ###
  Adapter method for client ready

  ###
  ready = (fn) ->
    isReady = false
    return unless fn
    readyFn = (client) ->
      return if isReady
      isReady = true
      fn(client)
    for platform, client of clients
      client.ready readyFn
    return

  ClientNotSupported: ClientNotSupported
  register: register
  unregister: unregister
  ready: ready
