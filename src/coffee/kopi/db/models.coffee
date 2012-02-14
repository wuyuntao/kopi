kopi.module("kopi.db.models")
  .require("kopi.exceptions")
  .require("kopi.events")
  .require("kopi.logging")
  .require("kopi.utils")
  .require("kopi.utils.array")
  .require("kopi.utils.klass")
  .require("kopi.utils.html")
  .require("kopi.utils.object")
  .require("kopi.utils.text")
  .require("kopi.utils.date")
  .require("kopi.db.collections")
  .require("kopi.db.queries")
  .require("kopi.db.errors")
  .define (exports, exceptions, events, logging
                  , utils, array, klass, html, object, text, date
                  , collections, queries, errors) ->

    logger = logging.logger(exports.name)

    # Enum of field types
    INTEGER = 0
    STRING = 1
    TEXT = 2
    FLOAT = 3
    DATETIME = 4
    JSON = 5

    PRIMARY = "primary"

    ###
    Meta class for all models
    ###
    class Meta

      # @type  {Hash}   Contain all scheme for models
      meta = {}

      this.get = (model) ->
        name = model.modelName()
        m = meta[name]
        if m
          if m.model != model
            throw new errors.ModelNameDuplicated(model)
          return m
        meta[name] = new Meta(model)

      constructor: (model) ->
        this.model = model
        this.pk = null
        this.fields = []
        this.names = {}
        this.belongsTo = []
        this.belongsToNames = {}
        this.hasMany = []
        this.hasManyNames = {}
        this.hasAndBelongsToMany = []
        this.adapters = {}
        this.defaultAdapterType = null

      prepare: ->
        for field in this.fields
          # Add field to name-field hash
          this.names[field.name] = field

        for relation in this.belongsTo
          model = relation.model
          # Convert model string to class
          if text.isString(model)
            model = relation.model = text.constantize(model)

          # Generate model name if not specified
          name = relation.name
          if not name
            name = relation.name = text.camelize(model.name, false)

          # Add primary key to model fields
          modelMeta = model.meta()
          pkName = name + text.camelize(modelMeta.pk)
          field = object.clone(modelMeta.names[modelMeta.pk])
          field.name = pkName
          field.isBelongsTo = true
          relation.pkName = pkName
          delete field.primary
          this.fields.push(field)
          this.names[pkName] = field
          this.belongsToNames[name] = relation

        for relation in this.hasMany
          model = relation.model
          # Convert model string to class
          if text.isString(model)
            model = relation.model = text.constantize(model)

          # Generate model name if not specified
          name = relation.name
          if not name
            name = relation.name = text.camelize(text.pluralize(model.name), false)
          this.hasManyNames[name] = relation

        if not this.pk
          throw new errors.PrimaryKeyNotFound(this.model)

        this

    ###
    Base class of all models

    Usage

      # Define blog model
      class Blog extends Model
        cls = this

        cls.adapter "server", RESTfulAdapter, primary: true
        cls.adapter "client", WebSQLAdapter

        cls.field "id", type: Model.INTEGER, primary: true
        cls.field "title", type: Model.STRING
        cls.field "description", type: Model.STRING

        cls.belongsTo "author.models.Author", name: "author"
        cls.hasMany Entry, name: "entries"
        cls.hasAndBelongsToMany Tag, name: "tags"

      saveFn = (error, blog) ->
        if not error
          # Blog is saved in local database successfully

      fetchFn = (error, blog) ->
        if not error
          # Save blog in local database
          blog.save saveFn, Blog.CLIENT

      # Fetch blog which id equals 1 from server
      Blog.get id: 1, fetchFn, Blog.SERVER
      # Or omit default adapter type
      Blog.get id: 1, fetchFn

    ###
    class Model extends events.EventEmitter

      kls = this

      klass.accessor kls, "modelName",
        get: -> this._modelName or= this.name
      klass.accessor kls, "dbName",
        get: ->
          meta = this.meta()
          meta.dbName or= this.modelName() or this.name
        set: (name) ->
          meta = this.meta()
          meta.dbName = name

      kls.adapter = (type=PRIMARY, adapter, options) ->
        cls = this
        meta = this.meta()
        # Define adapter getter
        if not adapter
          adapter = meta.adapters[type]
          if not adapter
            if type == PRIMARY
              throw new errors.PrimaryAdapterNotFound(cls)
            # else
            #   throw new errors.AdapterNotFound(cls, type)
          return adapter

        # Define adapter setter
        if not adapter.support(cls)
          logger.error "Adapter #{adapter.name} is not available."
          return cls
        # Provide constant string for adapter type. e.g. Blog.SERVER = "server"
        cls[text.underscore(type).toUpperCase()] or= type
        adapter = meta.adapters[type] = new adapter(options)
        if options and options.primary
          meta.adapters.primary = adapter
        cls

      ###
      Define a single field
      ###
      kls.field = (name, options={}) ->
        meta = this.meta()
        # If options is field type
        if text.isString(options)
          options =
            type: options

        # Set default field type
        if not options.type?
          options.type = STRING

        # Check if primary key field is duplicately defined
        if options.primary
          if meta.pk and meta.pk != name
            throw new errors.PrimaryKeyDuplicated(name)
          # Set primary key field
          meta.pk = name

        options.name = name
        meta.fields.push(options)
        this._prepared = false
        this

      ###
      Define one-to-many relationship
      ###
      kls.belongsTo = (model, options={}) ->
        meta = this.meta()
        options.model = model
        meta.belongsTo.push(options)
        this._prepared = false
        this

      ###
      Define many-to-one relationship
      ###
      kls.hasMany = (model, options={}) ->
        meta = this.meta()
        options.model = model
        meta.hasMany.push(options)
        this._prepared = false
        this

      ###
      Define many-to-many relationship
      ###
      kls.hasAndBelongsToMany = (model, options={}) ->
        meta = this.meta()
        options.model = model
        meta.hasAndBelongsToMany.push(options)
        this._prepared = false
        this

      ###
      Define query index
      ###
      kls.index = (field) ->
        meta = this.meta()
        meta.indices or= []
        meta.indices.push(field)
        this._prepared = false
        this

      ###
      Get meta for model
      ###
      kls.meta = -> Meta.get(this)

      ###
      Determine where two values equal to each other
      ###
      kls._valueEquals = (field, val1, val2) ->
        meta = this.meta()
        type = meta.names[field].type
        # Compare date objects with their
        if type == DATETIME
          val1 = if date.isDate(val1) then val1.getTime() else parseInt(val1)
          val2 = if date.isDate(val2) then val2.getTime() else parseInt(val2)
        val1 == val2

      ###
      Validates field definitions and creates some getter and setter methods for model

      ###
      # TODO Is it possible to move _prepare() to a meta class model
      kls.prepare = ->
        cls = this
        return cls if cls._prepared

        meta = cls.meta().prepare()
        proto = this.prototype

        ###
        Define getter and setter for regular fields.

        e.g.
          book.title            # returns 'Book'
          book.title = 'Title'  # returns 'Title'
        ###
        defineProp = (field) ->
          name = field.name
          getterFn = -> this._data[name]
          setterFn = (value) ->
            oldValue = this[name]
            unless cls._valueEquals(name, oldValue, value)
              this._data[name] = value
              this._dirty[name] = oldValue
              # this.emit cls.VALUE_CHANGE_EVENT, [this, name, value]
          object.defineProperty proto, name,
            get: getterFn
            set: setterFn

        for field in meta.fields
          defineProp(field)

        ###
        Define getter and setter for one-to-many relationships

        e.g.
          book.author                 # returns [Author 1]
          book.author = author2       # returns [Author 2]
        ###
        defineProp = (relation) ->
          name = relation.name
          pkName = relation.pkName

          getterFn = ->
            return null if not this._data[pkName]
            model = this._belongsTo[name]
            return model if model and model.pk() == this._data[pkName]
            throw new errors.RelatedModelNotFetched(cls, this.pk())
          setterFn = (value) ->
            oldPk = this._data[pkName]
            pk = if value.pk then value.pk() else value
            this[pkName] = pk

            unless this._valueEquals(pkName, oldPk, pk)
              if not value
                this._data[pkName] = null
                this._dirty[pkName] = oldPk
                this._belongsTo[name] = undefined
              else if value.pk
                this._data[pkName] = value.pk()
                this._dirty[pkName] = oldPk
                this._belongsTo[name] = value
              else
                # TODO Is it ok to assume it's an pk? Should we validate type for pk?
                this._data[pkName] = value
                this._dirty[pkName] = oldPk
                this._belongsTo[name] = undefined
              this.emit cls.VALUE_CHANGE_EVENT, [this, name, value]

          object.defineProperty proto, name,
            get: getterFn
            set: setterFn

        for relation in meta.belongsTo
          defineProp(relation)

        ###
        Define getter and setter for many-to-one relationships

        e.g.
          author.books
        ###
        defineProp = (relation) ->
          name = relation.name
          getterFn = ->
            collection = this._hasMany[name] or= []
            collection if collection
          setterFn = (value) ->
            this._hasMany[name] = value
            this.emit cls.VALUE_CHANGE_EVENT, [this, name, value]

          object.defineProperty proto, name,
            get: getterFn
            set: setterFn

        for relation in meta.hasMany
          defineProp(relation)

        cls._prepared = true
        cls

      ###
      Initialize database if neccessary
      @param {Function} fn
      @param {String}   type

      @return {kopi.db.models.Model}
      ###
      kls.init = (fn, type) ->
        cls = this
        cls.prepare().adapter(type).init(cls, fn)
        cls

      ###
      Create model from attributes

      @param {Hash}     attrs
      @param {Function} fn
      @param {String}   type

      @return {kopi.db.models.Model}
      ###
      kls.create = (attrs={}, fn, type) ->
        cls = this
        model = new cls(attrs)
        model.save fn, type
        cls

      ###
      Execute create query

      @param {Hash}     attrs
      @param {Function} fn
      @param {String}   type

      @return {kopi.db.models.Model}
      ###
      kls._create = (attrs={}, fn, type) ->
        cls = this
        new queries.CreateQuery(cls, attrs).execute(fn, type)
        cls

      ###
      Define shortcut methods for model. e.g. Model.where({})

      ###
      defineMethod = (method) ->
        kls[method] = ->
          new queries.RetrieveQuery(this)[method](arguments...)

      for method in queries.RetrieveQuery.ALL
        defineMethod(method)

      ###

      @param {Hash}     criteria
      @param {Hash}     attrs
      @param {Function} fn
      @param {String}   type

      @return {kopi.db.models.Model}
      ###
      kls._update = (criteria={}, attrs={}, fn, type) ->
        cls = this
        # TODO Return model object for callback function
        new queries.UpdateQuery(cls, null, attrs).where(criteria).execute(fn, type)
        cls

      ###

      @param {Hash}     criteria
      @param {Function} fn
      @param {String}   type
      @return {kopi.db.models.Model}
      ###
      kls._destroy = (criteria={}, fn, type) ->
        cls = this
        # TODO Return model object for callback function
        new queries.DestroyQuery(cls).where(criteria).execute(fn, type)
        cls

      kls.raw = (args..., fn, type) ->
        cls = this
        new queries.RawQuery(cls, args...).execute(fn, type)
        cls

      ###
      Model events
      ###
      kls.BEFORE_FETCH_EVENT = "beforefetch"
      kls.AFTER_FETCH_EVENT = "afterfetch"
      kls.BEFORE_SAVE_EVENT = "beforesave"
      kls.AFTER_SAVE_EVENT = "aftersave"
      kls.BEFORE_CREATE_EVENT = "beforecreate"
      kls.AFTER_CREATE_EVENT = "aftercreate"
      kls.BEFORE_UPDATE_EVENT = "beforeupdate"
      kls.AFTER_UPDATE_EVENT = "afterupdate"
      kls.BEFORE_DESTROY_EVENT = "beforedestroy"
      kls.AFTER_DESTROY_EVENT = "afterdestroy"
      kls.VALUE_CHANGE_EVENT = "change"

      ###
      @param  {Hash}  attrs
      ###
      constructor: (attrs={}) ->
        self = this
        cls = this.constructor
        cls.prefix or= text.underscore(cls.modelName())
        cls.prepare() if not cls._prepared

        self._meta = cls.meta()
        self.guid = utils.guid(cls.prefix)
        self._new = true
        self._type = cls.modelName()
        self._data = {}
        self._dirty = {}
        self._belongsTo = {}
        self._hasMany = {}
        self.isNew = true

        self.update(attrs)

      pk: ->
        this[this._meta.pk]

      equals: (model) ->
        this.pk() == model.pk()

      update: (attrs={}) ->
        cls = this.constructor
        self = this
        names = this._meta.names
        belongsTo = this._meta.belongsToNames
        hasMany = this._meta.hasManyNames
        for name, attribute of attrs
          if name of names or name of belongsTo or name of hasMany
            self[name] = attribute
        self

      ###
      Save model data

      @param {Function} fn    callback function
      @param {String}   type  adapter type
      @return {Model}         return self
      ###
      save: (fn, type) ->
        cls = this.constructor
        self = this
        pk = self.pk()
        pkName = self._meta.pk

        thenFn = (error) ->
          if not error
            self.emit if self.isNew then cls.AFTER_CREATE_EVENT else cls.AFTER_UPDATE_EVENT
            self.emit cls.AFTER_SAVE_EVENT
            self.isNew = false
          fn(error, self) if fn
        self.emit cls.BEFORE_SAVE_EVENT

        if not self.isNew
          criteria = {}
          criteria[pkName] = pk
          attrs = {}
          for field, value of self._dirty
            attrs[field] = self._data[field]
          self.emit cls.BEFORE_UPDATE_EVENT
          cls._update criteria, attrs, thenFn, type
        else
          self.emit cls.BEFORE_CREATE_EVENT
          cls._create object.clone(self._data), thenFn, type

        self

      ###
      Remove model data from client

      @return {Model}
      ###
      destroy: (fn, type) ->
        cls = this.constructor
        self = this
        criteria = {}
        criteria[self._meta.pk] = self.pk()
        thenFn = (error) ->
          if not error
            self.emit cls.AFTER_DESTROY_EVENT
          fn(error, self) if fn
        self.emit cls.BEFORE_DESTROY_EVENT
        cls._destroy(criteria, thenFn, type)
        self

      toString: ->
        "[#{this.constructor.modelName()} #{this.pk() or "null"}"

      ###
      Return a copy of model's attributes
      ###
      toJSON: -> object.clone this._data

    exports.INTEGER = INTEGER
    exports.STRING = STRING
    exports.TEXT = TEXT
    exports.FLOAT = FLOAT
    exports.DATETIME = DATETIME
    exports.JSON = JSON
    exports.Meta = Meta
    exports.Model = Model
