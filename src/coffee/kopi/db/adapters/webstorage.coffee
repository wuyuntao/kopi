kopi.module("kopi.db.adapters.webstorage")
  .require("kopi.logging")
  .require("kopi.utils.support")
  .require("kopi.db.adapters.kv")
  .require("kopi.db.models")
  .define (exports, logging, support, kv, models) ->

    logger = logging.logger(exports.name)
    storage = localStorage

    class StorageAdapater extends kv.KeyValueAdapter

      this.support = -> !!support.storage

      _get: (key, defautValue, fn) ->
        value = storage.getItem(key)
        fn(null, if value? then value else defautValue) if fn

      _set: (key, value, fn) ->
        try
          storage.setItem(key, value)
          fn(null) if fn
        catch e
          # TODO Any better handler for quota exceeded error
          if e == QUOTA_EXCEEDED_ERR
            logger.error(e)
            fn(e) if fn
          else
            throw e
        this

      _remove: (key, fn) ->
        storage.removeItem(key)
        fn(null) if fn
        this

      _adapterValue: (value, field) ->
        self = this
        switch field.type
          when models.DATETIME
            return value.getTime()
          when models.JSON
            return self._serialize(value)
          else
            super

      _modelValue: (value, field) ->
        self = this
        switch field.type
          when models.DATETIME
            new Date(value)
          when models.JSON
            self._deserialize(value)
          else
            super

      ###
      Save as string in local storage
      ###
      _serialize: (obj, fields) -> super(obj, fields, true)

      _deserialize: (string, fields) -> super(string, fields, true)

    exports.StorageAdapater = StorageAdapater
