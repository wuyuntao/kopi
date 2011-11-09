kopi.module("kopi.db.indexes")
  .require("kopi.events")
  .require("kopi.exceptions")
  .require("kopi.utils.array")
  .define (exports, events, exceptions, array) ->

    class DuplicateIndexError extends exceptions.Exception

    ###
    模型的索引对象
    ###
    class Index extends events.EventEmitter

      constructor: (model, field) ->
        this.model = model
        # @type {Object<value, id>}
        this.field = field
        this.reset()

      build: (collection) ->
        this.reset()
        self = this
        collection.forEach (model, i) ->
          key = "" + model[self.field]
          if key of self._index
            throw new DuplicateIndexError("Key '#{key}' already exists")
          self._index[key] = model
        self

      get: (key) -> this._index["" + key]

      reset: ->
        this._index = {}


    class PrimaryIndex extends Index

      constructor: (model) ->
        super(model, "id")

    exports.Index = Index
    exports.PrimaryIndex = PrimaryIndex
