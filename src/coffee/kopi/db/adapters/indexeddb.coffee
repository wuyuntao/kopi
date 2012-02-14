kopi.module("kopi.db.adapters.indexeddb")
  .require("kopi.logging")
  .require("kopi.utils.support")
  .require("kopi.db.adapters.kv")
  .define (exports, logging, support, client) ->

    win = window
    logger = logging.logger(exports.name)
    indexedDB = win.indexedDB or win.mozIndexedDB or win.webkitIndexedDB or win.msIndexedDB

    class IndexedDBAdapter extends kv.KeyValueAdapter

      this.support = -> !!support.indexedDB

      ###
      Open a database

      @param {String} name
      ###
      open: (name, fn) ->
        self = this
        req = indexedDB.open(name)
        req.onsuccess = (e) ->
          self._db = req.result
          fn(null, self._db) if fn
        req.onerror = (e) ->
          fn(e.target.errorCode) if fn
        self

      migrate: (fn) ->


    exports.IndexedDBAdapter = IndexedDBAdapter
