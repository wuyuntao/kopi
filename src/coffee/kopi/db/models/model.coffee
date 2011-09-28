kopi.module("kopi.db.models")
  .require("kopi.utils.html")
  .define (exports, html) ->

    ###
    所有模型的基类

    ###
    class Model

      ###
      @param  {Hash}  attributes    模型属性

      ###
      constructor: (attributes={}) ->

      ###
      从 HTML5 定义 MicroData 格式中获取数据

      @param  {String, jQuery Object, HTML Element} element   HTML 元素
      ###
      fromHTML: (element) ->
        self = this
        element = $(element)

        throw new Error("Can not find element") unless element.length

        if element.prop('itemscope')
          throw new Error("Element does not have 'itemscope' attribute")

        unless new RegExp("##{this.constructor.name}$").test(element.attr('itemtype'))
          throw new Error("Element does not have correct 'itemtype' attribute")

        $('[itemprop]', element).each ->
          prop = $(this)
          itemprop = prop.attr('itemprop')
          if itemprop in self.constructor.fields.keys()
            self[itemprop] = html.prop(prop)

    exports.Model = Model
