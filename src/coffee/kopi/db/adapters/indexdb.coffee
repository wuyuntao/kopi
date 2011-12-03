kopi.module("kopi.db.adapters.indexdb")
  .require("kopi.db.adapters.client")
  .define (exports, client) ->

    class IndexDBAdapter extends client.ClientAdapter

    exports.IndexDBAdapter = IndexDBAdapter
