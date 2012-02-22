define "kopi/utils/html", (require, exports, module) ->

  $ = require "jquery"
  exceptions = require "kopi/exceptions"

  ###
  根据不同 HTML Element 类型，获取 MicroData 数据，参考
  http://diveintohtml5.org/extensibility.html#property-values

  如果存在 itemattr 属性，则提取 itemattr 指定的属性

  @param  {HTML Element}  element
  @return {String}
  ###
  prop = (element) ->
    element = $(element)
    throw new exceptions.NoSuchElementError(element) unless element.length
    return element[element.attr('itemattr')] if element.attr('itemattr')

    switch element.attr('tagName')
      when "meta" then element.attr('content')
      when "audio", "video", "embed", "iframe", "image", "source" then element[0].src
      when "a", "area", "link" then element[0].href
      when "object" then element.attr('data')
      when "time" then element.attr('datatime')
      when "input" then element.val()
      else element.html()

  ###
  从 HTML5 定义 MicroData 格式中获取数据
  ###
  scope = (element) ->
    element = $(element)
    throw new exceptions.NoSuchElementError(element) unless element.length
    if element.prop('itemscope')
      throw new Error("Element does not have 'itemscope' attribute")
    data = {}
    $('[itemprop]', element).each ->
      el = $(this)
      data[el.attr('itemprop')] = prop(el)

  replaceClass = (element, regexp, replacement) ->
    element = $(element)
    throw new exceptions.NoSuchElementError(element) unless element.length
    for elem in element
      if elem.nodeType == 1
        elem.className = elem.className.replace(regexp, replacement)
    return

  removeClass = (element, regexp) ->
    replaceClass(element, regexp, "")

  prop: prop
  scope: scope
  replaceClass: replaceClass
  removeClass: removeClass
