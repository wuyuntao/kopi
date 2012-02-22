define "kopi/utils/object", (require, exports, module) ->

  func = require "kopi/utils/func"
  number = require "kopi/utils/number"
  text = require "kopi/utils/text"

  ObjectProto = Object.prototype

  ###
  Define jQuery-esque hash accessor

  ###
  accessor = (klass, method, property) ->
    property or= "_#{method}"
    klass[method] or= (name, value) ->
      obj = this[property] or= {}
      switch arguments.length
        when 0 then return obj
        when 1 then return obj[name]
        else return obj[name] = value
    return

  clone = (obj) -> extend {}, obj

  # Define custom property. e.g.
  # get: book.title
  # set: book.title = 1
  defineProperty = Object.defineProperty or= (obj, field, property={}) ->
    if property.get
      obj.__defineGetter__ field, -> property.get.call(this)
    if property.set
      obj.__defineSetter__ field, (value) ->
        property.set.call(this, value)
        value
    obj

  ###
  Define asynchronous property.

  Usage

    defineAsyncProperty book,
      get: (fn) ->
        asyncGetTitle (error, title) ->
          fn(error, title) if fn
      set: (title, fn) ->
        asyncSetTitle title, (error, title) ->
          fn(error, title) if fn

  Get book title asynchronously

    book.getTitle (error, title) -> console.log(error, title)

  Set book title asynchronously

    book.setTitle title, (error, title) -> console.log(error, title)

  ###
  defineAsyncProperty = (obj, field, property={}) ->
    field = text.capitalize(field)
    if property.get
      obj["get" + field] = ->
        property.get.apply(this, arguments)
        obj
    if property.set
      obj["set" + field] = ->
        property.set.apply(this, arguments)
        obj
    obj

  # Extend a given object with all of the properties in a source object.
  extend = (obj, mixins...) ->
    for mixin in mixins when mixin
      for name, method of mixin
        obj[name] = method
    obj

  isObject = (obj) ->
    type = typeof obj
    type == "object"

  keys = Object.keys or= (obj) ->
    (key for own key, val of obj)

  ObjectProto: ObjectProto
  accessor: accessor
  clone: clone
  defineProperty: defineProperty
  extend: extend
  isObject: isObject
  keys: keys
