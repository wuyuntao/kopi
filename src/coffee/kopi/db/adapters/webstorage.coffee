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

      _get: (key, defautValue) ->
        value = storage.getItem(key)
        if value? then value else defautValue

      _set: (key, value) ->
        try
          storage.setItem(key, value)
        catch e
          # TODO Any better handler for quota exceeded error
          if e == QUOTA_EXCEEDED_ERR
            logger.error(e)
          else
            throw e
        this

      _remove: (key) ->
        storage.removeItem(key)
        this

      _adapterValue: (value, field) ->
        self = this
        switch field.type
          when models.DATETIME
            return value.getTime()
          when models.JSON
            return self._stringify(value)
          else
            super

      _modelValue: (value, field) ->
        self = this
        switch field.type
          when models.DATETIME
            new Date(value)
          when models.JSON
            self._parse(value)
          else
            super

    exports.StorageAdapater = StorageAdapater
