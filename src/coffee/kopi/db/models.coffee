kopi.module("kopi.db.models")
  .require("kopi.utils.html")
  .require("kopi.utils.object")
  .require("kopi.utils.text")
  .require("kopi.events")
  .require("kopi.db.collections")
  # .require("kopi.db.indexes")
  .define (exports, html, object, text, events, collections) ->

    ###
    所有模型的基类

    ###
    class Model extends events.EventEmitter
      # @type {Hash}  字段的定义
      this._fields = {}
      this._belongsTo = {}
      this._hasMany = {}
      this._hasAndBelongsToMany = {}
      this._collection = collections.Collection
      # this._indexes = {}

      ###
      扩展字段的定义
      ###
      this.fields = (fields={}) ->
        object.extend this._fields, fields

      ###
      定义外键
      ###
      this.belongsTo = (model, options={}) ->
        if typeof model is "string"
          model = text.constantize(model)
        options.name or= model.name
        this._belongsTo[options.name] = model

      this.hasMany = (model, options={}) ->
        if typeof model is "string"
          model = text.constantize(model)
        options.name or= model.name
        this._hasMany[options.name] = model

      this.hasAndBelongsToMany = (model, options={}) ->
        if typeof model is "string"
          model = text.constantize(model)
        options.name or= model.name
        this._hasAndBelongsToMany[options.name] = model

      # this.index = (field) ->
      #   this._indexes[field] or= new Index(this, field)

      ###
      从 HTML5 定义 MicroData 格式中获取数据

      @param  {String, jQuery Object, HTML Element} element   HTML 元素
      @return {Array}                               模型列表
      ###
      this.fromHTML = (element, model) ->
        $(element).map -> (model or new this()).fromHTML(this)

      ###
      向服务器请求数据
      ###
      this.fromServer = (callback) ->

      ###
      ###
      this.create = (attributes={}, callback) ->
        model = new this(attributes)
        model.save(callback)

      ###
      返回查询对象

      @return   {Collection}  查询对象
      ###
      this.all = -> new collections.Collection(this)

      ###
      @param  {Hash}  attributes
      ###
      constructor: (attributes={}) ->
        this.update(attributes)

      ###
      @return {Boolean} 是否保存成功
      ###
      save: (callback) ->
        callback(this) if $.isFunction(callback)

      ###
      @return {Boolean} 是否删除成功
      ###
      destroy: (callback) ->
        callback(this) if $.isFunction(callback)

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
        element = $(element)
        unless element.length
          throw new Error("Can not find element")
        unless new RegExp("##{this.constructor.name}$").test(element.attr('itemtype'))
          throw new Error("Element does not have correct 'itemtype' attribute")
        this.update(html.scope(element))

      ###
      事件的模板方法
      ###
      # oncreate: -> true
      # onsave: -> true
      # onupdate: -> true
      # ondestroy: -> true

    exports.Model = Model
