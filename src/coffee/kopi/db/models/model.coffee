kopi.module("kopi.db.models")
  .require("kopi.utils.html")
  .define (exports, html) ->

    ###
    所有模型的基类

    ###
    class Model
      cls = this

      ###
      从 HTML5 定义 MicroData 格式中获取数据

      @param  {String, jQuery Object, HTML Element} element   HTML 元素
      ###
      cls.fromHTML = (element, model) ->
        (model or new this()).fromHTML(element)

      ###
      @param  {Hash}  attributes
      ###
      constructor: (attributes={}) ->

      ###
      @param  {Hash}  attributes
      ###
      update: (attributes={}) ->
        for field, value of attributes
          this[field] = value

      ###
      从 HTML5 定义 MicroData 格式中获取数据

      @param  {String, jQuery Object, HTML Element} element   HTML 元素
      ###
      fromHTML: (element) ->
        element = $(element)
        throw new Error("Can not find element") unless element.length
        unless new RegExp("##{this.constructor.name}$").test(element.attr('itemtype'))
          throw new Error("Element does not have correct 'itemtype' attribute")
        this.update(html.scope(element))

    exports.Model = Model
