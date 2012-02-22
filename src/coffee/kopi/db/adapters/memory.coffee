define "kopi/db/adapters/memory", (require, exports, module) ->

  storage = require "kopi/utils/storage"
  webstorage = require "kopi/db/adapters/webstorage"

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

  MemoryAdapter: MemoryAdapter
