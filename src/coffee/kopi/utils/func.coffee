kopi.module("kopi.utils.func")
  .require("kopi.utils.text")
  .define (exports) ->

    # Is the given value a function?
    isFunction = (fn) ->
      !!(fn and fn.constructor and fn.call and fn.apply)

    send = (fn, context, args...) ->
      return fn unless isFunction(fn)
      fn.apply(context, args)

    exports.isFunction = isFunction
    exports.send = send
