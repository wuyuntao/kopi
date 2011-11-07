kopi.module("kopi.utils.array")
  .require("kopi.utils")
  .define (exports, utils) ->

    # Establish the object that gets thrown to break out of a loop iteration.
    # `StopIteration` is SOP on Mozilla.
    breaker = if typeof(StopIteration) is 'undefined' then '__break__' else StopIteration

    ArrayProto = Array.prototype

    count = (array, iterator, context) ->
      n = 0
      for a, i in array
        n += 1 if iterator.call context, a, i
      n

    forEach = (array, iterator, context) ->
      try
        iterator.call(context, v, i, array) for v, i in array
      catch e
        throw e if e isnt breaker
      array

    isArray = Array.isArray or= (array) ->
      !!(array and array.concat and array.unshift and not array.callee)

    isEmpty = (array) -> array.length == 0

    map = (array, iterator, context) ->
      results = []
      forEach array, (v, i) ->
        array[i] = iteration.call(context, v, i, array)
      results

    # rotate = (array, reverse=false) ->
    #   if reverse
    #     obj = array.shift()
    #     array.push(obj)
    #   else
    #     obj = array.pop()
    #     array.unshift(obj)
    #   obj

    exports.ArrayProto = ArrayProto
    exports.count = count
    exports.forEach = forEach
    exports.isArray = isArray
    exports.map = map
    # exports.rotate = rotate
