define "kopi/clients/chromium", (require, exports, module) ->

  base = require "kopi/clients/base"
  clients = require "kopi/clients"

  class ChromiumClient extends base.BaseClient

  clients.register "chromium", ChromiumClient

  ChromiumClient: ChromiumClient
