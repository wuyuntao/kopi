kopi.module("kopi.db.models")
  .require("kopi.exceptions")
  .require("kopi.events")
  .require("kopi.utils")
  .require("kopi.utils.func")
  .require("kopi.utils.html")
  .require("kopi.utils.object")
  .require("kopi.utils.text")
  .require("kopi.db.collections")
  # .require("kopi.db.indexes")
  .define (exports, exceptions, events
                  , utils, func, html, object, text
                  , collections) ->

    ###
    所有模型的基类

    ###
    class Model extends events.EventEmitter
      cls = this
      # @type {Hash}  字段的定义
      cls._fields = {}
      cls._belongsTo = {}
      cls._hasMany = {}
      cls._hasAndBelongsToMany = {}
      cls._collection = collections.Collection
      cls._adapters = []
      # cls._indexes = {}

      ###
      扩展字段的定义
      ###
      cls.fields = (fields={}) ->
        object.extend this._fields, fields

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

      cls.adapters = (adapters) ->
        unless array.isArray(adapters)
          adapters = [adapters]
        this._adapters.concat adapters

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
        self._adapters = {}

        fieldDefineProp = (field) ->
          fieldGetterFn = -> self[field]
          fieldSetterFn = (value) ->
            oldValue = self[field]
            unless self._valueEquals(value, oldValue)
              self[field] = value
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

      equals: (model) ->
        self.guid == model.guid

      ###
      @return {Boolean} 是否保存成功
      ###
      save: (callback) ->
        callback(this) if func.isFunction(callback)

      ###
      @return {Boolean} 是否删除成功
      ###
      destroy: (callback) ->
        callback(this) if func.isFunction(callback)

      ###
      @param  {Hash}  attributes
      ###
      update: (attributes={}) ->
        fields = Object.keys(this.constructor.fields)
        for own field, value of attributes when field in fields
          this[field] = value
        this

      ###
      从 HTML5 定义 MicroData 格式中获取数据

      @param  {String, jQuery Object, HTML Element} element   HTML 元素
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

      toJSON: ->
        throw new exceptions.NotImplementedError()

      fromJSON: ->
        throw new exceptions.NotImplementedError()

      ###
      事件的模板方法
      ###
      # oncreate: -> true
      # onsave: -> true
      # onupdate: -> true
      # ondestroy: -> true

    exports.Model = Model
