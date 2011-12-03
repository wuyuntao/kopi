kopi.module("kopi.db.adapters.memory")
  .require("kopi.utils.storage")
  .require("kopi.db.adapters.webstorage")
  .define (exports, storage) ->

    storage = storage.memoryStorage

    class MemoryAdapter extends kv.KeyValueAdapter

      support: -> !!storage

      _get: (key, value) ->
        storage.getItem(key) or value
        this

      _set: (key, value) ->
        storage.setItem(key, value)

      _remove: (key) ->
        storage.removeItem(key)
        this

    exports.MemoryAdapter = MemoryAdapter
