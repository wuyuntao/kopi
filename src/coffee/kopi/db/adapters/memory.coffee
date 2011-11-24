kopi.module("kopi.db.adapters.memory")
  .require("kopi.db.adapters.kv")
  .define (exports, kv) ->

    class MemoryAdapter extends kv.KeyValueAdapter

    exports.MemoryAdapter = MemoryAdapter
