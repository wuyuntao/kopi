kopi.module("kopi.db.adapters.webstorage")
  .require("kopi.logging")
  .require("kopi.utils.support")
  .require("kopi.db.adapters.kv")
  .define (exports, logging, support, kv) ->

    logger = logging.logger(exports.name)
    storage = localStorage

    class StorageAdapater extends kv.KeyValueAdapter

      this.support = -> !!storage

      _get: (key, value) ->
        storage.getItem(key) or value
        this

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

    exports.StorageAdapater = StorageAdapater
