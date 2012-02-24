define "kopi/clients/android", (require, exports, module) ->

  base = require "kopi/clients/base"
  clients = require "kopi/clients"

  class AndroidClient extends base.BaseClient

  clients.register "android", AndroidClient

  AndroidClient: AndroidClient
