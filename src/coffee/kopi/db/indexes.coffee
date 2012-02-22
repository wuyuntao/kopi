define "kopi/db/indexes", (require, exports, module) ->

  events = require "kopi/events"
  exceptions = require "kopi/exceptions"
  array = require "kopi/utils/array"

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

  Index: Index
  PrimaryIndex: PrimaryIndex
