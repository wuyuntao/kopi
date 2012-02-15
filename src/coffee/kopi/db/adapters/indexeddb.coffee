kopi.module("kopi.db.adapters.indexeddb")
  .require("kopi.logging")
  .require("kopi.settings")
  .require("kopi.utils.indexeddb")
  .require("kopi.utils.support")
  .require("kopi.db.models")
  .require("kopi.db.adapters.client")
  .define (exports, logging, settings, idb, support, models, client) ->

    win = window
    logger = logging.logger(exports.name)

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
        request = idb.indexedDB.open(settings.kopi.db.indexedDB.name)
        request.onsuccess = (e) ->
          self._db = request.result
          self._db.onerror = (e) ->
          fn(null, self._db) if fn
        request.onerror = (e) ->
          self._db = null
          fn(e.target.errorCode) if fn
        request.onupgradeneeded = (e) ->
          self._db = request.result
          self._db.createObjectStore(model.dbName(), keyPath: model.meta().pk)
        self

      create: (query, fn) ->
        self = this
        store = self._store(query.model.dbName(), true)
        meta = query.model.meta()
        value = self._adapterObject(query.attrs(), meta.names)
        request = store.add(value)
        request.onsuccess = (e) ->
          fn(null, pk: e.target.result[meta.pk]) if fn
        request.onerror = (e) ->
          fn(request.errorCode) if fn
        self

      update: (query, fn) ->
        self = this
        store = self._store(query.model.dbName(), true)
        value = self._adapterObject(query.attrs(), query.model.meta().names)
        request = store.put(value)
        request.onsuccess = (e) ->
          fn(null) if fn
        request.onerror = (e) ->
          fn(request.errorCode) if fn
        self

      retrieve: (query, fn) ->
        # TODO Retrieve multiple objects with IDBCursor
        self = this
        store = self._store(query.model.dbName())
        request = store.get(query.pk())
        request.onsuccess = (e) ->
          message =
            ok: true
            entries: [self._modelObject(request.result, query.model.meta().names)]
          fn(null, message) if fn
        request.onerror = (e) ->
          fn(request.errorCode) if fn
        self

      destroy: (query, fn) ->
        self = this
        store = self._store(query.model.dbName(), true)
        request = store.delete(query.pk())
        request.onsuccess = (e) ->
          fn(null) if fn
        request.onerror = (e) ->
          fn(request.errorCode) if fn
        self

      ###
      Create transaction and return object store
      ###
      _store: (storeName, write=false, fn) ->
        transaction = this._db.transaction(storeName,
          if write then IDBTransaction.READ_WRITE else IDBTransaction.READ_ONLY)
        transaction.oncomplete = (e) ->
          fn(null, e, transaction) if fn
        transaction.onerror = (e) ->
          # TODO Replace true with error code or message
          fn(true, e, transaction) if fn
        transaction.objectStore(storeName)


      _adapterValue: (value, field) ->
        self = this
        switch field.type
          when models.DATETIME
            return value.getTime()
          when models.JSON
            return self._adapterObject(value)
          else
            super

      _modelValue: (value, field) ->
        self = this
        switch field.type
          when models.DATETIME
            new Date(value)
          when models.JSON
            self._modelObject(value)
          else
            super

    exports.indexedDB = idb.indexedDB
    exports.IndexedDBAdapter = IndexedDBAdapter
