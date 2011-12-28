kopi.module("kopi.clients.ios")
  .require("kopi.clients.base")
  .define (exports, base) ->

    class IOSClient extends base.BaseClient

    exports.IOSClient = IOSClient
