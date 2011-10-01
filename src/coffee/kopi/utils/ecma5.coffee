###
为 JavaScript 提供 ECMAScript5 的一些特性

部分代码来自于 underscore.coffee
###
kopi.module("kopi.utils.ecma5")
  .require("kopi.utils")
  .define (exports, utils) ->

    # Establish the object that gets thrown to break out of a loop iteration.
    # `StopIteration` is SOP on Mozilla.
    breaker = if typeof(StopIteration) is 'undefined' then '__break__' else StopIteration

    ArrayProto = Array.prototype
    ObjectProto = Object.prototype

    # All **ECMA5** native implementations we hope to use are declared here.
    ArrayProto.forEach or= (iterator, context) ->
      try
        iterator.call context, this[i], i, this for i in [0...this.length]
      catch e
        throw e if e isnt breaker
      this

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
