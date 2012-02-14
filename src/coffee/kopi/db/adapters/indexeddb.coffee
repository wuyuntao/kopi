kopi.module("kopi.db.adapters.indexeddb")
  .require("kopi.logging")
  .require("kopi.settings")
  .require("kopi.utils.support")
  .require("kopi.db.adapters.client")
  .define (exports, logging, settings, support, client) ->

    win = window
    logger = logging.logger(exports.name)
    indexedDB = win.indexedDB or win.mozIndexedDB or win.webkitIndexedDB or win.msIndexedDB
    IDBTransaction = win.IDBTransaction or win.webkitIDBTransaction or win.msIDBTransaction

    class IndexedDBAdapter extends client.ClientAdapter

      this.support = -> !!support.indexedDB

      ###
      Open a database

      @param {String} name
      ###
      init: (model, fn) ->
        self = this
        if self._db
          fn(null, self._db) if fn
          return self
        req = indexedDB.open(settings.kopi.db.indexedDB.name)
        req.onsuccess = (e) ->
          self._db = req.result
          self._db.onerror = (e) ->
            console.log e
          fn(null, self._db) if fn
        req.onerror = (e) ->
          fn(e.target.errorCode) if fn
        req.onupgradeneeded = (e) ->
          self._db.createObjectStore(model.dbName(), keyPath: model.meta().pk)
        self

      create: (query, fn) ->
        self = this
        storeName = query.model.dbName()
        transaction = self._db.transaction([storeName], IDBTransaction.READ_WRITE)
        transaction.oncomplete = (e) ->
          fn(null) if fn
        transaction.onerror = (e) ->
          fn(true) if fn
        store = transaction.objectStore(name)
        req = store.add(value)
        req.onsuccess = (e) ->
          # event.target.result == customerData[i].ssn
          console.log e
          console.log request.result
        req.onerror = (e) ->
          console.log e
          fn(request.errorCode) if fn
        self

      update: (query, fn) ->
        self = this
        storeName = query.model.dbName()
        transaction = self._db.transaction(storeName, IDBTransaction.READ_WRITE)
        transaction.oncomplete = (e) ->
          fn(null) if fn
        transaction.onerror = (e) ->
          fn(true) if fn
        store = transaction.objectStore(storeName)
        req = store.put(value, query.pk())
        req.onsuccess = (e) ->
          console.log e
          console.log request.result
        req.onerror = (e) ->
          console.log e
          fn(request.errorCode) if fn
        self

      retrieve: (query, fn) ->
        self = this
        storeName = query.model.dbName()
        console.log storeName
        transaction = self._db.transaction(storeName)
        store = transaction.objectStore(storeName)
        request = store.get(query.pk())
        request.onsuccess = (e) ->
          console.log e
          console.log request.result
          fn(null, request.result) if fn
        request.onerror = (e) ->
          console.log e
          fn(request.errorCode) if fn
        self

      destroy: (query, fn) ->
        self = this
        storeName = query.model.dbName()
        transaction = self._db.transaction(storeName, IDBTransaction.READ_WRITE)
        store = transaction.objectStore(storeName)
        request = store.delete(query.pk())
        request.onsuccess = (e) ->
          console.log e
          console.log request
          fn(null) if fn
        request.onerror = (e) ->
          console.log e
          console.log request
          fn(request.errorCode)
        self

    exports.IndexedDBAdapter = IndexedDBAdapter
