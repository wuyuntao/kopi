define "kopi/db/queries", (require, exports, module) ->

  exceptions = require "kopi/exceptions"
  utils = require "kopi/utils"
  klass = require "kopi/utils/klass"
  number = require "kopi/utils/number"
  object = require "kopi/utils/object"

  ###
  Some query related exception
  ###
  class QueryError extends exceptions.Exception

  CREATE = "create"
  RETRIEVE = "retrieve"
  UPDATE = "update"
  DESTROY = "destroy"
  RAW = "raw"
  ACTIONS = [CREATE, RETRIEVE, UPDATE, DESTROY, RAW]

  ONLY = "only"
  WHERE = "where"
  SORT = "sort"
  SKIP = "skip"
  LIMIT = "limit"
  COUNT = "count"
  ONE = "one"
  ALL = "all"

  LT = "lt"
  LTE = "lte"
  GT = "gt"
  GTE = "gte"
  EQ = "eq"
  NE = "ne"
  IN = "in"
  NIN = "nin"
  IS = "IS"
  LIKE = "LIKE"
  ILIKE = "ILIKE"

  ###
  Kopi provides a query API similar to MongoDB.

  Define a query to retrieve books which are collected by some user

    base = new RetrieveQuery(Book)
      .only("sid", "title")
      .where(userId: user.sid)
      .sort(collectedAt: false)
    count = base.clone()
      .count(true)
    query = base.clone()
      .skip(10)
      .limit(10)

  Define a query with advanced condition filters

    query = new RetrieveQuery(Book)
      .where
        userId:
          in: [1, 3, 5]
        registerAt:
          lte: new Date(2011, 12, 1)
          gt: new Date(2011, 11, 1)
        lastName:
          like: /smith|johnson/
        firstName:
          ne: "josh"

  Define a query to create a comment of a book
    query = new CreateQuery(Comment)
      .attrs(bookId: book.sid, body: "Then again")

  Define a query to update multiple comments
    query = new UpdateQuery(Comment)
      .where(userId: user.sid, bookId: book.sid)
      .attrs(privacy: Comment.PRIVACY_PUBLIC)

  ###
  class BaseQuery

    this.METHODS = []

    proto = this.prototype
    klass.accessor proto, "action"

    constructor: (model, criteria) ->
      cls = this.constructor
      self = this
      if not model
        throw new exceptions.ValueError("Model must be a subclass of kopi.db.models.Model")

      # Set default values
      self.model = model

      if criteria
        for method in cls.METHODS
          self[method](criteria[method]) if method of criteria

    clone: -> throw new exceptions.NotImplementedError()

    # Generate AJAX params
    params: -> throw new exceptions.NotImplementedError()

    # Generate SQL statements
    sql: -> throw new exceptions.NotImplementedError()

    criteria: ->
      cls = this.constructor
      self = this
      criteria = {}
      for method in cls.METHODS
        value = self[method]()
        criteria[method] = value if value
      criteria

    execute: (fn, type) ->
      self = this
      adapter = self.model.prepare().adapter(type)
      adapter[self._action](self, fn)
      this

  class CreateQuery extends BaseQuery

    proto = this.prototype
    klass.accessor proto, "attrs",
      value: {}
      set: (attrs) ->
        if this._attrs then object.extend(this._attrs, attrs) else this._attrs = attrs

    constructor: (model, attrs={}) ->
      this.action(CREATE).attrs(attrs)
      super(model)

    params: -> {attrs: JSON.stringify(this._attrs)}

    clone: -> new this.constructor(this.model, this._attrs)

    pk: ->
      self = this
      self._attrs[self.model.meta().pk]

  class BaseRetriveQuery extends BaseQuery

    kls = this
    kls.METHODS = [WHERE, SKIP, LIMIT]
    kls.OPERATIONS = [LT, LTE, GT, GTE, EQ, NE, IN, NIN, IS, LIKE, ILIKE]

    proto = this.prototype
    klass.accessor proto, "where",
      value: {}
      set: (where) ->
        this._where or= {}
        for field, operations of where
          this._where[field] or= {}
          unless this._isOpertions(operations)
            operations =
              eq: operations
          object.extend this._where[field], operations

    klass.accessor proto, "skip",
      set: (skip) ->
        this._skip = skip if number.isNumber(skip)

    klass.accessor proto, "limit",
      set: (limit) ->
        this._limit = limit if number.isNumber(limit)

    constructor: (model, criteria) ->
      self = this
      super(model, criteria)

    ###
    If value is an hash and all keys are operation keywords,
    value is considered as a operation hash

    TODO Need to optimize performance?
    ###
    _isOpertions: (obj) ->
      if object.isObject(obj)
        for key, value of obj
          unless key in this.constructor.OPERATIONS
            return false
        return true
      false

    clone: ->
      cls = this.constructor
      self = this
      new cls(self.model, self.criteria())

    pk: ->
      self = this
      criteria = self.criteria()
      try
        pk = criteria.pk.eq
      catch e
        try
          pk = criteria.where[self.model.meta().pk].eq
        catch e
          pk = null
      pk

  class RetrieveQuery extends BaseRetriveQuery

    this.METHODS = [ONLY, WHERE, SORT, SKIP, LIMIT, COUNT]
    this.ALL = this.METHODS.concat [ONE, ALL]

    proto = this.prototype
    klass.accessor proto, "only",
      set: ->
        this._only = arguments

    klass.accessor proto, "sort",
      value: {}
      set: (sort) ->
        this._sort or= {}
        object.extend this._sort, sort

    constructor: (model, criteria) ->
      self = this
      self.action(RETRIEVE)
      self._count = false
      super(model, criteria)

    count: (fn, type) ->
      self = this
      return self._count if not arguments.length
      self._count = true
      self.execute(fn, type)

    one: (fn, type) ->
      self = this
      # Force limit to 1
      self._limit = 1
      retrieveFn = (error, result) ->
        if error
          fn(error, result) if fn
          return
        # Build model
        if result.length > 0
          model = new self.model(result[0])
          model.isNew = false
        else
          model = null
        fn(error, model) if fn
      self.execute(retrieveFn, type)

    all: (fn, type) ->
      self = this
      retrieveFn = (error, result) ->
        if error
          fn(error, result) if fn
          return
        # Build collection
        collection = []
        if result.length > 0
          for entry, i in result
            model = new self.model(entry)
            model.isNew = false
            collection.push(model)
        fn(error, collection) if fn
      self.execute(retrieveFn, type)

  class UpdateQuery extends BaseRetriveQuery

    proto = this.prototype
    klass.accessor proto, "attrs",
      value: {}
      set: (attrs) ->
        if this._attrs then object.extend(this._attrs, attrs) else this._attrs = attrs

    constructor: (model, criteria, attrs={}) ->
      this.action(UPDATE).attrs(attrs)
      super(model, criteria)

    clone: ->
      cls = this.constructor
      self = this
      new cls(self.model, self.criteria(), self._attrs)

  class DestroyQuery extends BaseRetriveQuery

    constructor: (model, criteria) ->
      this.action(DESTROY)
      super(model, criteria)

  class RawQuery extends BaseQuery

    klass.accessor this.prototype, "args"

    constructor: (model, args...) ->
      this.action(RAW)
      this.args(args)
      super(model)

    clone: -> new this.constructor(this.model, this.args()...)

  CREATE: CREATE
  RETRIEVE: RETRIEVE
  UPDATE: UPDATE
  DESTROY: DESTROY
  RAW: RAW
  ACTIONS: ACTIONS

  LT: LT
  LTE: LTE
  GT: GT
  GTE: GTE
  EQ: EQ
  NE: IN
  IN: IN
  NIN: NIN
  IS: IS
  LIKE: LIKE
  ILIKE: ILIKE

  CreateQuery: CreateQuery
  RetrieveQuery: RetrieveQuery
  UpdateQuery: UpdateQuery
  DestroyQuery: DestroyQuery
  RawQuery: RawQuery
