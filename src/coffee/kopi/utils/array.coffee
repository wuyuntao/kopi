kopi.module("kopi.utils.array")
  .require("kopi.utils")
  .define (exports, utils) ->

    # TODO support objects and number
    count = (obj, iterator, context) ->
      n = 0
      for o, i in obj
        n += 1 if iterator.call context, o, i
      n

    exports.count = count
