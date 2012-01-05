kopi.module("kopi.native.android")
  .require("kopi.native.base")
  .define (exports, base) ->

    class AndroidClient extends base.BaseClient

    exports.AndroidClient = AndroidClient
