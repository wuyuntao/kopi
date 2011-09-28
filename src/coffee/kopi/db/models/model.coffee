kopi.module("kopi.db.models")
  .require("kopi.utils.html")
  .define (exports, html) ->

    ###
    所有模型的基类

    ###
    class Model
      this.fields = {}

      ###
      从 HTML5 定义 MicroData 格式中获取数据

      @param  {String, jQuery Object, HTML Element} element   HTML 元素
      @return {Array}                               模型列表
      ###
      this.fromHTML = (element, model) ->
        $(element).map -> (model or new this()).fromHTML(this)

      this.create = (attributes={}, callback) ->
        model = new this(attributes)
        model.save(callback)

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
        for field, value of attributes when field in fields
          this[field] = value

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

    exports.Model = Model
