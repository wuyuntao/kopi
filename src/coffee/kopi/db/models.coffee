kopi.module("kopi.db.models")
  .require("kopi.exceptions")
  .require("kopi.events")
  .require("kopi.utils")
  .require("kopi.utils.func")
  .require("kopi.utils.html")
  .require("kopi.utils.object")
  .require("kopi.utils.text")
  .require("kopi.db.collections")
  .require("kopi.db.exceptions")
  # .require("kopi.db.indexes")
  .define (exports, exceptions, events
                  , utils, func, html, object, text
                  , collections, errors) ->

    ###
    所有模型的基类

    Usage

    class Blog extends Model
      cls = this
      cls.adapters
        server:
          RESTfulAdapter
        client:
          [IndexDBAdapter, WebSQLAdapter, localStorageAdapter, MemoryAdapter]

      cls.fields
        id:
          type: Model.INTEGER
          primary: true
        title:
          type: Model.STRING

      cls.belongsTo Author
      cls.hasMany Entry
      cls.hasAndBelongsToMany Tag

    ###
    class Model extends events.EventEmitter
      cls = this
      # @type {Hash}  字段的定义
      cls._fields = {}
      cls._fieldNames = []
      cls._pkName = null
      cls._belongsTo = {}
      cls._hasMany = {}
      cls._hasAndBelongsToMany = {}
      cls._collection = collections.Collection
      cls._adapters = {}
      # cls._indexes = {}

      ###
      Define accessor of adapters for model
      ###
      cls.adapters = (typeOrAdapters) ->
        cls = this
        return cls._adapters if not typeOrAdapters
        return cls._adapters[typeOrAdapters] if text.isString(typeOrAdapters)
        for type, adapters of adapters
          unless array.isArray(adapters)
            cls._adapters[type] = new adapters(cls) if adapters.support(cls)
            continue
          for adapter in adapters
            cls._adapters[type] = new adapters(cls) if adapters.support(cls)
            continue

      ###
      扩展字段的定义
      ###
      cls.fields = (fields={}) ->
        cls = this
        for name, field of fields
          # Setup primary key field
          if fields.primary
            throw new errors.DuplicatePkField(cls._pkName) if cls._pkName
            cls._pkName = name
          # Convert string to field object
          if text.isString(field)
            field =
              type: field
          cls._fields[name] = field
        # Update field names
        cls._fieldNames = object.keys(cls.fields)

      ###
      定义外键
      ###
      cls.belongsTo = (model, options={}) ->
        if typeof model is "string"
          model = text.constantize(model)
        options.name or= model.name
        this._belongsTo[options.name] = model

      cls.hasMany = (model, options={}) ->
        if typeof model is "string"
          model = text.constantize(model)
        options.name or= model.name
        this._hasMany[options.name] = model

      cls.hasAndBelongsToMany = (model, options={}) ->
        if typeof model is "string"
          model = text.constantize(model)
        options.name or= model.name
        this._hasAndBelongsToMany[options.name] = model

      # cls.index = (field) ->
      #   this._indexes[field] or= new Index(this, field)

      ###
      从 HTML5 定义 MicroData 格式中获取数据

      @param  {String, jQuery Object, HTML Element} element   HTML 元素
      @return {Array}                               模型列表
      ###
      cls.fromHTML = (element, model) ->
        $(element).map -> (model or new this()).fromHTML(this)

      ###
      向服务器请求数据
      ###
      cls.fromServer = (callback) ->

      ###
      ###
      cls.create = (attributes={}, callback) ->
        model = new this(attributes)
        model.save(callback)

      ###
      返回查询对象

      @return   {Collection}  查询对象
      ###
      cls.all = -> new collections.Collection(this)

      ###
      Model events
      ###
      cls.BEFORE_FETCH_EVENT = "beforefetch"
      cls.AFTER_FETCH_EVENT = "afterfetch"
      cls.BEFORE_SAVE_EVENT = "beforesave"
      cls.AFTER_SAVE_EVENT = "aftersave"
      cls.BEFORE_CREATE_EVENT = "beforecreate"
      cls.AFTER_CREATE_EVENT = "aftercreate"
      cls.BEFORE_UPDATE_EVENT = "beforeupdate"
      cls.AFTER_UPDATE_EVENT = "afterupdate"
      cls.BEFORE_DESTROY_EVENT = "beforedestroy"
      cls.AFTER_DESTROY_EVENT = "afterdestroy"

      ###
      @param  {Hash}  attributes
      ###
      constructor: (attributes={}) ->
        self = this
        cls = this.constructor
        cls.prefix or= text.underscore(cls.name)

        self.guid = utils.guid(cls.prefix)
        self._new = true
        self._type = cls.name
        self._dirtyProperties = {}
        self._data = {}

        fieldDefineProp = (field) ->
          fieldGetterFn = ->
            self._data[field]
          fieldSetterFn = (value) ->
            oldValue = self[field]
            unless self._valueEquals(value, oldValue)
              self._data[field] = value
              self._dirtyProperties[field] = oldValue
              self.emit "set change", [self, field, value]
          object.defineProperty self, field,
            get: fieldGetterFn,
            set: fieldSetterFn

        defaultValue = (field) ->
          value = cls._fields[field]["default"]
          # TODO Get default values by field type

        for field, scheme of cls._fields
          if cls._fields.hasOwnProperty(field)
            fieldDefineProp(field)
          self[field] = defaultValue(field)

        self.update(attributes)

      pk: ->
        this[this.constructor._pkName]

      ###
      @return {Hash}  A clone of data
      ###
      data: ->
        object.clone(this._data)

      equals: (model) ->
        self.guid == model.guid

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

      ###
      # TODO Move to HTML adapter/proxy
      ###
      toJSON: ->
        throw new exceptions.NotImplementedError()

      fromJSON: ->
        throw new exceptions.NotImplementedError()

    exports.Model = Model
