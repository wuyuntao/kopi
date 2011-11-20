kopi.module("kopi.utils.object")
  .require("kopi.utils.func")
  .require("kopi.utils.number")
  .define (exports, func, number) ->

    ObjectProto = Object.prototype

    clone = (obj) -> extend {}, obj

    defineProperty = Object.defineProperty or= (obj, field, property={}) ->
      if func.isFunction(property.get)
        obj.__defineGetter__ field, -> property.get.call(this)
      if func.isFunction(property.set)
        obj.__defineSetter__ field, (value) -> property.set.call(this, value)

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
      key for own key, val of obj

    exports.ObjectProto = ObjectProto
    exports.clone = clone
    exports.defineProperty = defineProperty
    exports.extend = extend
    exports.isObject = isObject
    exports.keys = keys
