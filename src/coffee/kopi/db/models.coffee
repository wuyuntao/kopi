kopi.module("kopi.db.models")
  .require("kopi.exceptions")
  .require("kopi.events")
  .require("kopi.logging")
  .require("kopi.utils")
  .require("kopi.utils.array")
  .require("kopi.utils.klass")
  .require("kopi.utils.func")
  .require("kopi.utils.html")
  .require("kopi.utils.object")
  .require("kopi.utils.text")
  .require("kopi.utils.date")
  .require("kopi.db.collections")
  .require("kopi.db.errors")
  .define (exports, exceptions, events, logging
                  , utils, array, klass, func, html, object, text, date
                  , collections, errors) ->

    logger = logging.logger(exports.name)

    # Enum of field types
    INTEGER = 0
    STRING = 1
    TEXT = 2
    FLOAT = 3
    DATETIME = 4
    BLOB = 5

    ###
    Meta class for all models
    ###
    class Meta

      # @type  {Hash}   Contain all scheme for models
      meta = {}

      this.get = (model) ->
        name = model.name
        m = meta[name]
        if m
          if m.model != model
            throw new errors.DuplicateModelNameError(model)
          return m
        meta[name] = new Meta(model)

      constructor: (model) ->
        this.model = model
        this.pk = null
        this.fields = []
        this.names = {}
        this.belongsTo = []
        this.hasMany = []
        this.hasAndBelongsToMany = []

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
          modelMeta = model._meta()
          pkName = name + text.camelize(modelMeta.pk)
          field = object.clone(modelMeta.names[modelMeta.pk])
          field.name = pkName
          field.isBelongsTo = true
          relation.pkName = pkName
          delete field.primary
          this.fields.push(field)
          this.names[pkName] = field

        for relation in this.hasMany
          model = relation.model
          # Convert model string to class
          if text.isString(model)
            model = relation.model = text.constantize(model)

          # Generate model name if not specified
          name = relation.name
          if not name
            name = relation.name = text.camelize(text.pluralize(model.name), false)

        if not this.pk
          throw new errors.PrimaryKeyNotFoundError(this.model)

        this

    ###
    Base class of all models

    Usage

      class Blog extends Model
        cls = this
        cls.adapters
          server:
            RESTfulAdapter
          client:
            [IndexDBAdapter, WebSQLAdapter, StorageAdapter, MemoryAdapter]

        cls.field "id", type: Model.INTEGER, primary: true
        cls.field "title", type: Model.STRING
        cls.field "description", type: Model.STRING

        cls.belongsTo "author.models.Author", name: "author"
        cls.hasMany Entry, name: "entries"
        cls.hasAndBelongsToMany Tag, name: "tags"

    ###
    class Model extends events.EventEmitter
      kls = this

      ###
      Define accessor of adapters for model
      ###
      kls.adapters = (typeOrAdapters) ->
        cls = this
        cls._adapters or= {}
        return cls._adapters if not typeOrAdapters
        return cls._adapters[typeOrAdapters] if text.isString(typeOrAdapters)
        for type, adapters of adapters
          unless array.isArray(adapters)
            cls._adapters[type] = new adapters(cls) if adapters.support(cls)
            continue
          for adapter in adapters
            cls._adapters[type] = new adapters(cls) if adapters.support(cls)
            continue
        cls

      ###
      Define a single field
      ###
      kls.field = (name, options={}) ->
        meta = this._meta()
        # If options is field type
        if text.isString(options)
          options =
            type: options

        # Set default field type
        if not options.type
          options.type = STRING

        # Check if primary key field is duplicately defined
        if options.primary
          if meta.pk and meta.pk != name
            throw new errors.DuplicatePrimaryKeyError(name)
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
        meta = this._meta()
        options.model = model
        meta.belongsTo.push(options)
        this._prepared = false
        this

      ###
      Define many-to-one relationship
      ###
      kls.hasMany = (model, options={}) ->
        meta = this._meta()
        options.model = model
        meta.hasMany.push(options)
        this._prepared = false
        this

      ###
      Define many-to-many relationship
      ###
      kls.hasAndBelongsToMany = (model, options={}) ->
        meta = this._meta()
        options.model = model
        meta.hasAndBelongsToMany.push(options)
        this._prepared = false
        this

      ###
      Define query index
      ###
      kls.index = (field) ->
        meta = this._meta()
        meta.indices or= []
        meta.indices.push(field)
        this._prepared = false
        this

      ###
      Get meta for model
      ###
      kls._meta = -> Meta.get(this)

      ###
      Determine where two values equal to each other
      ###
      kls._valueEquals = (field, val1, val2) ->
        meta = this._meta()
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
      kls._prepare = ->
        cls = this
        return cls if cls._prepared

        meta = cls._meta().prepare()
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
            collection = this._hasMany[name] or []
            collection if collection
          setterFn = (value) ->
            throw new exceptions.NotImplementedError()

          object.defineProperty proto, name,
            get: getterFn
            set: setterFn

        for relation in meta.hasMany
          defineProp(relation)

        cls._prepared = true
        cls

      ###
      从 HTML5 定义 MicroData 格式中获取数据

      @param  {String, jQuery Object, HTML Element} element   HTML 元素
      @return {Array}                               模型列表
      ###
      kls.fromHTML = (element, model) ->
        $(element).map -> (model or new this()).fromHTML(this)

      ###
      向服务器请求数据
      ###
      kls.fromServer = (callback) ->

      ###
      ###
      kls.create = (attributes={}, callback) ->
        model = new this(attributes)
        model.save(callback)

      ###
      返回查询对象

      @return   {Collection}  查询对象
      ###
      kls.all = -> new collections.Collection(this)

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
      @param  {Hash}  attributes
      ###
      constructor: (attributes={}) ->
        self = this
        cls = this.constructor
        cls.prefix or= text.underscore(cls.name)
        cls._prepare() if not cls._prepared

        self._meta = cls._meta()
        self.guid = utils.guid(cls.prefix)
        self._new = true
        self._type = cls.name
        self._data = {}
        self._dirty = {}
        self._belongsTo = {}
        self._hasMany = {}

        self.update(attributes)

      # TODO Modify pk() as a custom property
      pk: ->
        this[this._meta.pk]

      ###
      @return {Hash}  A clone of data
      ###
      data: ->
        object.clone(this._data)

      equals: (model) ->
        this.guid == model.guid

      update: (attributes={}) ->
        cls = this.constructor
        self = this
        names = this._meta.names
        for name, attribute of attributes
          if name of names
            self[name] = attribute
        self

      ###
      Fetch model data from server

      @return {Model}
      ###
      fetch: ->

      ###
      Store model data to client

      @return {Model}
      ###
      save: (fn) ->
        cls = this.constructor
        self = this
        pkName = cls._pkName
        data = self.data()
        pk = data[pkName]
        create = false
        thenFn = (error) ->
          self.emit if create then cls.AFTER_CREATE_EVENT else cls.AFTER_UPDATE_EVENT
          self.emit cls.AFTER_SAVE_EVENT
          if error
            # TODO logging or emitting
          else
            # TODO logging or emitting
          fn(error, self) if func.isFunction(fn)
        self.emit cls.BEFORE_SAVE_EVENT
        if pk
          criteria = {}
          criteria[pkName] = pk
          delete data[pkName]
          # TODO Check which fields need to be updated?
          self.emit cls.BEFORE_UPDATE_EVENT
          cls.update criteria, data, thenFn
        else
          self.emit cls.BEFORE_CREATE_EVENT
          cls.create data, thenFn
          create = true
        self

      ###
      Remove model data from client

      @return {Model}
      ###
      destroy: (fn) ->
        cls = this.constructor
        self = this
        criteria = {}
        criteria[pkName] = pk
        thenFn = (error) ->
          self.emit cls.AFTER_DESTROY_EVENT
          if error
            # TODO logging or emitting
          else
            # TODO logging or emitting
          fn(error, self) if func.isFunction(fn)
        self.emit cls.BEFORE_DESTROY_EVENT
        cls.destroy(criteria, thenFn)
        self

      attr: (name, value) ->
        if field of this.constructor._fieldNames
          this[name] = value
        this

      ###
      @param  {Hash}  attributes
      ###
      attrs: (data={}) ->
        for own name, value of data when field of this.constructor._fieldNames
          this[name] = value
        this

      ###
      从 HTML5 定义 MicroData 格式中获取数据

      @param  {String, jQuery Object, HTML Element} element   HTML 元素

      # TODO Move to HTML adapter/proxy
      ###
      fromHTML: (element) ->
        cls = this.constructor
        element = $(element)
        unless element.length
          throw new exceptions.NoSuchElementError("Can not find element")

        cls.RE_ITEM_TYPE or= new RegExp("##{this.constructor.name}$")
        unless cls.RE_ITEM_TYPE.test(element.attr('itemtype'))
          throw new exceptions.NoSuchElementError("Element does not have correct 'itemtype' attribute")
        this.update(html.scope(element))

      toString: ->
        "[#{this.name} #{this.pk() or "null"}"

      ###
      # TODO Move to HTML adapter/proxy
      ###
      toJSON: ->
        throw new exceptions.NotImplementedError()

      fromJSON: ->
        throw new exceptions.NotImplementedError()

      _valueEquals: (field, value) ->
        false

    exports.INTEGER = INTEGER
    exports.STRING = STRING
    exports.TEXT = TEXT
    exports.FLOAT = FLOAT
    exports.DATETIME = DATETIME
    exports.BLOB = BLOB
    exports.Model = Model
