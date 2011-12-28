kopi.module("kopi.clients.chromium")
  .require("kopi.clients.base")
  .define (exports, base) ->

    class ChromiumClient extends base.BaseClient

    exports.ChromiumClient = ChromiumClient
