define "kopi/db/adapters/indexeddb", (require, exports, module) ->

  exceptions = require "kopi/exceptions"
  logging = require "kopi/logging"
  settings = require "kopi/settings"
  support = require "kopi/utils/support"
  models = require "kopi/db/models"
  queries = require "kopi/db/queries"
  client = require "kopi/db/adapters/client"

  win = window
  logger = logging.logger(module.id)

  class IndexedDBError extends exceptions.Exception

    constructor: (code, message) ->
      this.code = code
      this.message = message

  ###
  Adapter for IndexedDB

  ###
  class IndexedDBAdapter extends client.ClientAdapter

    this.support = -> !!support.indexedDB

    constructor: (options) ->
      super
      this._options.version or= "1"

    ###
    Open a database and migrate to current version

    @param {String} name
    ###
    init: (model, fn) ->
      self = this
      if self._db
        fn(null, self._db) if fn
        return self
      version = self._options.version
      request = indexedDB.open(settings.kopi.db.indexedDB.name, version)
      request.onsuccess = (e) ->
        db = self._db = request.result
        # For lagacy API with setVersion() available (on earlier version of Chrome)
        if db.setVersion? and db.version != version
          setVersionRequest = db.setVersion(version)
          setVersionRequest.onsuccess = (e) ->
            self.migrate(model)
            fn(null, db) if fn
          setVersionRequest.onfailure = (e) ->
            code = setVersionRequest.errorCode
            message = support.prop("errorMessage", setVersionRequest)
            logger.error "Failed to set version for database. Error code: #{code}. #{message}"
            fn(new IndexedDBError(code, message)) if fn
        else
          fn(null, self._db) if fn
      request.onerror = (e) ->
        self._db = null
        code = request.errorCode
        message = support.prop("errorMessage", request)
        logger.error "Failed to open database. Error code: #{code}. #{message}"
        fn(new IndexedDBError(code, message)) if fn
      # For W3C latest spec (on Mozilla Firefox)
      request.onupgradeneeded = (e) ->
        self._db = request.result
        self.migrate(model)
      self

    ###


    TODO Implement as an event
    ###
    migrate: (model) ->
      meta = model.meta()
      store = this._db.createObjectStore(meta.dbName, keyPath: meta.pk)
      for index in meta.indexes
        # TODO Support index optional parameters
        try
          store.createIndex(index, index)
        catch e
          logger.error(e)

    create: (query, fn) ->
      self = this
      meta = query.model.meta()
      store = self._store(meta.dbName, true)
      value = self._adapterObject(query.attrs(), meta.names)
      request = store.add(value)
      request.onsuccess = (e) ->
        fn(null, pk: e.target.result[meta.pk]) if fn
        return
      request.onerror = (e) ->
        code = request.errorCode
        message = support.prop("errorMessage", request)
        logger.error "Failed to create object. Error code: #{code}. #{message}"
        fn(new IndexedDBError(code, message)) if fn
        return
      self

    retrieve: (query, fn) ->
      self = this
      fields = query.model.meta().names
      isCount = query.count()
      only = query.only()
      limit = query.limit()
      skip = query.skip()
      result = if isCount then 0 else []
      request = self._cursor(query)
      request.onsuccess = (e) ->
        cursor = e.target.result
        if cursor
          # Skip first results
          if skip > 0
            skip -= 1
            cursor.continue()
            return

          # Return limited result
          if limit and (isCount and result == limit) or (not isCount and result.length == limit)
            fn(null, result) if fn
            return

          # Increase counter or append object
          if isCount
            result += 1
          else
            value = cursor.value
            result.push(self._modelObject(value, fields))
          cursor.continue()
        else
          fn(null, result) if fn
      request.onerror = (e) ->
        code = request.errorCode
        message = support.prop("errorMessage", request)
        logger.error "Failed to retrieve objects. Error code: #{code}. #{message}"
        fn(new IndexedDBError(code, message)) if fn
      self

    update: (query, fn) ->
      # TODO Support advance querying
      self = this
      meta = query.model.meta()
      store = self._store(meta.dbName, true)
      value = self._adapterObject(query.attrs(), meta.names)
      request = store.put(value)
      request.onsuccess = (e) ->
        fn(null) if fn
      request.onerror = (e) ->
        code = request.errorCode
        message = support.prop("errorMessage", request)
        logger.error "Failed to update objects. Error code: #{code}. #{message}"
        fn(new IndexedDBError(code, message)) if fn
      self

    destroy: (query, fn) ->
      # TODO Support advance querying
      self = this
      store = self._store(query.model.dbName(), true)
      request = store.delete(query.pk())
      request.onsuccess = (e) ->
        fn(null) if fn
      request.onerror = (e) ->
        code = request.errorCode
        message = support.prop("errorMessage", request)
        logger.error "Failed to destroy objects. Error code: #{code}. #{message}"
        fn(new IndexedDBError(code, message)) if fn
      self

    ###
    Create transaction and return object store
    ###
    _store: (storeName, write=false, fn) ->
      transaction = this._db.transaction(storeName,
        if write then IDBTransaction.READ_WRITE else IDBTransaction.READ_ONLY)
      transaction.oncomplete = (e) ->
        fn(null) if fn
      transaction.onerror = (e) ->
        code = transaction.errorCode
        message = support.prop("errorMessage", transaction)
        fn(new IndexedDBError(code, message)) if fn
      transaction.objectStore(storeName)

    ###
    Create object store cursor for query

    Limitations:
      1. IndexedDB only supports one field querying, if where condition has multiple
         fields, it will raise an exception
      2. IndexedDB only supports following condition filters:
         lt, lte, gt, gte, eq, ne

    TODO Extend multi-field querying and extra filters in JavaScript side?
    ###
    _cursor: (query) ->
      self = this
      meta = query.model.meta()
      fields = meta.names
      pk = meta.pk
      store = self._store(meta.dbName)
      openCursor = null
      queryKey = null
      for field, condition of query.where()
        if queryKey?
          throw new queries.QueryError("IndexedDB does not support multi-field querying.")
        # Open primary key cursor
        if field is pk
          queryKey = field
          context = store
          keyRange = self._keyRange(condition, fields[field])
          break
        else if field in meta.indexes
          queryKey = field
          index = store.index(field)
          context = index
          keyRange = self._keyRange(condition, fields[field])
      if not queryKey?
        queryKey = pk
        context = store
        keyRange = null

      sortKey = null
      direction = IDBCursor.NEXT
      for field, ascending of query.sort()
        if sortKey? or field != queryKey
          throw new queries.QueryError("IndexedDB does not support multi-field sorting.")
        sortKey = field
        direction = IDBCursor.PREV if not ascending

      context.openCursor(keyRange, direction)

    _keyRange: (condition, field) ->
      self = this
      value = (op) -> self._adapterValue(condition[op], field)
      if queries.EQ of condition
        return IDBKeyRange.only(value(queries.EQ))
      else
        lowerBound = null
        upperBound = null
        if queries.LT of condition
          upperBound = [value(queries.LT), true]
        else if queries.LTE of condition
          upperBound = [value(queries.LTE), false]
        if queries.GT of condition
          lowerBound = [value(queries.GT), true]
        else if queries.GTE of condition
          lowerBound = [value(queries.GTE), false]

        if lowerBound and not upperBound
          return IDBKeyRange.lowerBound(lowerBound...)
        else if upperBound and not lowerBound
          return IDBKeyRange.upperBound(upperBound...)
        else if lowerBound and upperBound
          return IDBKeyRange.bound(lowerBound[0], upperBound[0], lowerBound[1], upperBound[1])

      return null

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

  IndexedDBAdapter: IndexedDBAdapter
