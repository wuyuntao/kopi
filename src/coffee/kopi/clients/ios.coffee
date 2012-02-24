define "kopi/clients/ios", (require, exports, module) ->

  base = require "kopi/clients/base"
  clients = require "kopi/clients"

  class IOSClient extends base.BaseClient

  clients.register "ios", IOSClient

  IOSClient: IOSClient
