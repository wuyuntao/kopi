kopi.module("kopi.clients.android")
  .require("kopi.clients.base")
  .define (exports, base) ->

    class AndroidClient extends base.BaseClient

    exports.AndroidClient = AndroidClient
