kopi.module("kopi.db.queries")
  .require("kopi.exceptions")
  .require("kopi.utils")
  .require("kopi.utils.number")
  .require("kopi.utils.object")
  .require("kopi.db.models")
  .define (exports, exceptions, utils, number, object, models) ->

    CREATE = "create"
    RETRIEVE = "retrieve"
    UPDATE = "update"
    DESTROY = "destroy"
    ACTIONS = [CREATE, RETRIEVE, UPDATE, DESTROY]

    ###
    Kopi provides a query API similar to MongoDB.

    Define a query to retrieve books which are collected by some user

      base = new RetrieveQuery(Book)
        .type(RetrieveQuery.SERVER)
        .only("sid", "title")
        .where(userId: user.sid)
        .sort(collectedAt: false)
      count = base.clone()
        .count(true)
      query = base.clone()
        .skip(10)
        .limit(10)

    Define a query to create a comment of a book
      query = new CreateQuery(Comment)
        .type(CreateQuery.SERVER)
        .attrs(bookId: book.sid, body: "Then again")

    Define a query to update multiple comments
      query = new UpdateQuery(Comment)
        .type(type(UpdateQuery.SERVER)
        .where(userId: user.sid, bookId: book.sid)
        .attrs(privacy: Comment.PRIVACY_PUBLIC)

    ###
    class BaseQuery

      cls = this
      cls.SERVER = "server"
      cls.CLIENT = "client"
      cls.TYPES = [cls.SERVER, cls.CLIENT]
      cls.METHODS = ["type"]

      constructor: (model, criteria) ->
        cls = this.constructor
        self = this
        if not model
          throw new exceptions.ValueError("Model must be a subclass of kopi.db.models.Model")

        # Set default values
        self._model = model

        if criteria
          for method in cls.METHODS
            self[method](criteria[method]) if method of criteria

      type: (type) ->
        cls = this.constructor
        if type in cls.TYPES
          this._type = type
        this

      execute: (fn) ->
        throw new exceptions.NotImplementedError()

      clone: ->
        throw new exceptions.NotImplementedError()

      _adapter: ->
        adapter = this._model.adapters(this._type)
        if not adapter
          throw new exceptions.ValueError("No #{this._type} adapter in #{this._model.name} model")
        adapter

      criteria: ->
        cls = this.constructor
        self = this
        criteria = {}
        for method in cls.METHODS
          value = self["_#{method}"]
          criteria[method] = value if value

    class CreateQuery extends BaseQuery

      constructor: (model, attrs={}, criteria) ->
        this._action = CREATE
        this._attrs = attrs
        super(model, criteria)

      attrs: (attrs) ->
        this._attrs = attrs
        this.clone()

      execute: (fn) ->
        this._adapter.create(this, fn)

      clone: ->
        new this.constructor(this._model, this._attrs).type(this._type)

    class BaseRetriveQuery extends BaseQuery

      this.METHODS = ["type", "where", "skip", "limit"]

      constructor: (model, criteria) ->
        self = this
        self._where = null
        self._skip = null
        self._limit = null
        super(model, criteria)

      where: (criteria) ->
        if object.isObject(criteria)
          this._where = criteria
        this

      skip: (skip) ->
        if number.isNumber(skip)
          this._skip = skip
        this

      limit: (limit) ->
        if number.isNumber(limit)
          this._limit = limit
        this

      clone: ->
        cls = this.constructor
        self = this
        new cls(self._model, self.criteria())

    class RetrieveQuery extends BaseRetriveQuery

      this.METHODS = ["type", "only", "where", "sort", "skip", "limit", "count"]

      constructor: (model, criteria) ->
        self = this
        self._action = RETRIEVE
        self._only = null
        self._sort = null
        self._count = false
        super(model, type, criteria)

      only: ->
        if arguments.length
          this._only = arguments
        this

      sort: (sort) ->
        if object.isObject(sort)
          this._sort = sort
        this

      count: (count) ->
        this._count = !!count
        this

    class UpdateQuery extends BaseRetriveQuery

      constructor: (model, criteria, attrs) ->
        this._action = UPDATE
        this._attrs = attrs
        super(model, criteria)

      attrs: (attrs) ->
        this._attrs = attrs if attrs
        this

      clone: ->
        cls = this.constructor
        self = this
        new cls(self._model, self.criteria(), self._attrs)

    class DestroyQuery extends BaseRetriveQuery

      constructor: (model, type, criteria) ->
        this._action = DESTROY
        super(model, type, criteria)

    exports.CREATE = CREATE
    exports.RETRIEVE = RETRIEVE
    exports.UPDATE = UPDATE
    exports.DESTROY = DESTROY
    exports.ACTIONS = ACTIONS
    exports.CreateQuery = CreateQuery
    exports.RetrieveQuery = RetrieveQuery
    exports.UpdateQuery = UpdateQuery
    exports.DestroyQuery = DestroyQuery
