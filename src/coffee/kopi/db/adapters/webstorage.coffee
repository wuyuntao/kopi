kopi.module("kopi.db.adapters.webstorage")
  .require("kopi.db.adapters.kv")
  .define (exports, kv) ->

    class LocalStorageAdapater extends kv.KeyValueAdapter

    exports.LocalStorageAdapater = LocalStorageAdapater
