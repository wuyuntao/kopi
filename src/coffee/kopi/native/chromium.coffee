kopi.module("kopi.native.chromium")
  .require("kopi.native.base")
  .define (exports, base) ->

    class ChromiumClient extends base.BaseClient

    exports.ChromiumClient = ChromiumClient
