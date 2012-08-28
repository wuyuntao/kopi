define "kopi/utils/html", (require, exports, module) ->

  $ = require "jquery"
  exceptions = require "kopi/exceptions"

  ###
  Get micro data property from HTML elements.
  Ref: http://diveintohtml5.org/extensibility.html#property-values

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
  Get micro data from HTML elements
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

  ###
  Replace specified CSS class for the set of matched elements
  ###
  replaceClass = (element, regexp, replacement) ->
    element = $(element)
    throw new exceptions.NoSuchElementError(element) unless element.length
    for elem in element
      if elem.nodeType == 1
        elem.className = elem.className.replace(regexp, replacement)
    return

  ###
  A fast method to remove CSS class from element
  ###
  removeClass = (element, regexp) ->
    replaceClass(element, regexp, "")

  prop: prop
  scope: scope
  replaceClass: replaceClass
  removeClass: removeClass
