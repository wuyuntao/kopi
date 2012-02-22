define "kopi/db/adapters/sql", (require, exports, module) ->

  exceptions = require "kopi/exceptions"
  queries = require "kopi/db/queries"
  client = require "kopi/db/adapters/client"

  class SQLAdapter extends client.ClientAdapter

    create: (query, fn) ->

    retrieve: (query, fn) ->

    update: (query, fn) ->

    destroy: (query, fn) ->

    executeSql: (sql, args, fn) ->

    ###
    Build sql from query
    ###
    _sql: (query) ->
      self = this
      switch query.action
        when queries.RETRIEVE
          return self._select(query)
        when queries.CREATE
          return self._create(query)
        when queries.UPDATE
          return self._update(query)
        when queries.DESTROY
          return self._destroy(query)
        else
          throw new exceptions.ValueError("query action not correct.")

    _select: (query) ->
      model = query.model
      table = model.tableName()
      select = "SELECT #{} FROM #{table}"
      sql = [select]
      params = []

    _create: (query) ->

    _update: (query) ->

    _delete: (query) ->

    _columns: (query) ->
      return '*' if not query.only()
      query.only.join(", ")

    ###
    Build where sql from where object

    @return {Array} sql and params
    ###
    _where: (where) ->

    _createTable: (model, safe=true) ->
      table = model.tableName()
      fields = []
      # for field in model.fields()

  SQLAdapter: SQLAdapter
