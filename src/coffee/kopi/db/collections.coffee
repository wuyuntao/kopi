kopi.module("kopi.db.collections")
  .require("kopi.events")
  .require("kopi.exceptions")
  .require("kopi.utils.array")
  .define (exports, events, exceptions, array) ->

    ###
    模型的查询对象
    ###
    class Collection extends events.EventEmitter

      constructor: (model) ->
        this.model = model
        this._collection = []

      # {{{ Public methods
      add: (models, options) ->
        if array.isArray(models)
          for model in models
            this._add(model, options)
        else
          this._add(models, options)
        this

      remove: (models, options) ->
        if array.isArray(models)
          for model in models
            this._remove(model, options)
        else
          this._remove(models, options)
        this

      create: (model) ->

      update: (attr) ->

      get: (callback) ->

      find: (callback) ->

      fetch: ->

      count: ->

      where: ->
        this

      sort: ->
        this

      desc: ->
        this

      asc: ->
        this

      limit: (n) ->
        this
      # }}}

      # {{{ Private methods
      _add: (model) ->
        this._collection.push(model)

      _remove: (model) ->
        array.remove(this._collection, model)

      _reset: ->
        this._collection = []

      # }}}

    exports.Collection = Collection
