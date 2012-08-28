define "kopi/utils/func", (require, exports, module) ->

  ###
  # Function utilities
  #
  ###

  text = require "kopi/utils/text"

  ###
  ## isFunction(fn)

  Is the given value a function?

  ```coffeescript
  # return: true
  func = require "kopi/utils/func"
  func.isFunction(-> console.log("This is a function."))
  ###
  isFunction = (fn) ->
    !!(fn and fn.constructor and fn.call and fn.apply)

  ## Exports
  isFunction: isFunction
