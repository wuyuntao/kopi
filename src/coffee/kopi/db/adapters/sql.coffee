kopi.module("kopi.db.adapters.sql")
  .require("kopi.db.adapters.client")
  .define (exports, client) ->

    class SQLAdapter extends client.ClientAdapter

    exports.SQLAdapter = SQLAdapter
