kopi.module("kopi.utils.object")
  .require("kopi.utils.array")
  .require("kopi.utils.number")
  .define (exports, utils) ->

    ObjectProto = Object.prototype

    keys = Object.keys or= (object) ->
      return number.range(0, object.length) if array.isArray(obj)
      key for key, val of obj

    exports.ObjectProto = ObjectProto
    exports.keys = keys
