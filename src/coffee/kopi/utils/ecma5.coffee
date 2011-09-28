###
为 JavaScript 提供 ECMAScript5 的一些特性

部分代码来自于 underscore.coffee
###
kopi.module("kopi.utils.ecma5")
  .require("kopi.utils")
  .define (exports, utils) ->

  ArrayProto = Array.prototype
  ObjectProto = Object.prototype

  # All **ECMA5** native implementations we hope to use are declared here.
  # ArrayProto.forEach
  # ArrayProto.map
  # ArrayProto.reduce
  # ArrayProto.reduceRight
  # ArrayProto.filter
  # ArrayProto.every
  # ArrayProto.some
  # ArrayProto.indexOf
  # ArrayProto.lastIndexOf

  exports.isArray = Array.isArray or= (obj) ->
    !!(obj and obj.concat and obj.unshift and not obj.callee)

  exports.keys = Object.keys or= (obj) ->
    return utils.range(0, obj.length) if Array.isArray(obj)
    key for key, val of obj
