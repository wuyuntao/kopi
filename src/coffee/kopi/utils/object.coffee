kopi.module("kopi.utils.object")
  .require("kopi.utils.array")
  .require("kopi.utils.number")
  .define (exports, array) ->

    ObjectProto = Object.prototype

    # Extend a given object with all of the properties in a source object.
    extend = (obj, mixins...) ->
      for mixin in mixins when mixin
        for name, method of mixin
          obj[name] = method
      obj

    keys = Object.keys or= (obj) ->
      return number.range(0, obj.length) if array.isArray(obj)
      key for own key, val of obj

    exports.ObjectProto = ObjectProto
    exports.extend = extend
    exports.keys = keys
