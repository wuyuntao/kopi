kopi.module("kopi.utils.html")
  .define (exports) ->

    ###
    根据不同 HTML Element 类型，获取 MicroData 数据，参考
    http://diveintohtml5.org/extensibility.html#property-values

    如果存在 itemattr 属性，则提取 itemattr 指定的属性

    @param  {HTML Element}  element
    @return {String}
    ###
    prop = (element) ->
      element = $(element)
      throw new Error("Must specify element") unless element.length
      return element[element.attr('itemattr')] if element.attr('itemattr')

      switch element.attr('tagName')
        when "meta" then element.attr('content')
        when "audio", "video", "embed", "iframe", "image", "source" then element[0].src
        when "a", "area", "link" then element[0].href
        when "object" then element.attr('data')
        when "time" then element.attr('datatime')
        when "input" then element.val()
        else then element.html()

    exports.prop = prop
