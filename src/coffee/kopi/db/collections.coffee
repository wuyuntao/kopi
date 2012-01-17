kopi.module("kopi.db.collections")
  .require("kopi.events")
  .require("kopi.exceptions")
  .require("kopi.utils.array")
  .define (exports, events, exceptions, array) ->

    ###
    Collection of model objects

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
        for model in this._collection
          model.update(attr)
        this

      get: () ->

      find: () ->

      fetch: ->

      count: ->
        this._collection.length

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

      getOrCreateBy: (filter, fn) ->
        self = this
        created = false
        saveDoneFn = (chapter) ->
          fn(null, chapter, created) if fn
        saveFailFn = (error) ->
          fn(error) if fn
        saveThenFn = (error, chapter) ->
          if error then saveFailFn(error) else saveDoneFn(chapter)
        queryDoneFn = (chapter) ->
          if not chapter
            chapter = new self.model(filter)
            created = true
          chapter.save saveThenFn
        queryFailFn = (error) ->
          fn(error) if fn
        queryThenFn = (error, chapter) ->
          if error then queryFailFn(error) else queryDoneFn(chapter)
        self.where(filter).one queryThenFn

      # }}}

      # {{{ Private methods
      _add: (model) ->
        if not model instanceof self.model
          throw new exceptions.ValueError("Model must be an instance of #{self.model.name}")
        this._collection.push(model)

      _remove: (model) ->
        array.remove(this._collection, model)

      _reset: ->
        this._collection = []

      # }}}

    exports.Collection = Collection
