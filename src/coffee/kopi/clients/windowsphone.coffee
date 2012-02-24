define "kopi/clients/windowsphone", (require, exports, module) ->

  base = require "kopi/clients/base"
  clients = require "kopi/clients"

  class WindowsPhoneClient extends base.BaseClient

  clients.register "windowsphone", WindowsPhoneClient

  WindowsPhoneClient: WindowsPhoneClient
