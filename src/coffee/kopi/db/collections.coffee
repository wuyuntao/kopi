kopi.module("kopi.db.collections")
  .define (exports) ->

    ###
    模型的查询对象
    ###
    class Collection
      constructor: (model) ->
        this.model = model if model

      create: ->

      destroy: ->

      update: ->

      get: (callback) ->

      find: (callback) ->

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

    exports.Collection = Collection
