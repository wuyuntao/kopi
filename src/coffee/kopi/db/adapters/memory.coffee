define "kopi/db/adapters/memory", (require, exports, module) ->

  storage = require("kopi/utils/storage").memoryStorage
  KeyValueAdapter = require("kopi/db/adapters/kv").KeyValueAdapter

  class MemoryAdapter extends KeyValueAdapter

    this.support = -> !!storage

    _get: (key, defautValue, fn) ->
      value = storage.getItem(key)
      value = if value? then value else defautValue
      fn(null, value) if fn
      value

    _set: (key, value, fn) ->
      storage.setItem(key, value)
      fn(null) if fn
      value

    _remove: (key, fn) ->
      value = storage.removeItem(key)
      fn(null) if fn
      value

  MemoryAdapter: MemoryAdapter
