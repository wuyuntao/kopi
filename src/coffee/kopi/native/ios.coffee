kopi.module("kopi.native.ios")
  .require("kopi.native.base")
  .define (exports, base) ->

    class IOSClient extends base.BaseClient

    exports.IOSClient = IOSClient
