kopi.module("kopi.db.adapters.client")
  .require("kopi.db.adapters.base")
  .define (exports, base) ->

    class ClientAdapter extends base.BaseAdapter

    exports.ClientAdapter = ClientAdapter
