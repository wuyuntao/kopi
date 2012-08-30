define "kopi/utils/func", (require, exports, module) ->

  ###
  # Function utilities
  #
  ###

  array = require "kopi/utils/array"
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

  ###
  ## asyncCall(tasks, fn[, context])

  ```coffeescript
  add = (a, b, done) -> done(a + b)
  multi = (c, d, done) -> done(c * d)
  methods = [
    [add, 1, 2]
    [multi, 2, 3]
  ]
  func.asyncCall methods, (results) ->
    # output: 3
    console.log results[0]
    # output: 5
    console.log results[1]
  ```

  ###
  asyncCall = (tasks, fn, context) ->
    results = []
    iterFn = (args, i, done) ->
      func = args.shift()
      args.push ->
        results[i] = arguments
        done(results)
      func.apply context, args
    array.asyncForEach tasks, iterFn, fn
    tasks

  ###
  ## asyncParCall(tasks, fn[, context])

  ###
  asyncParCall = (tasks, fn, context) ->
    results = []
    iterFn = (args, i, done) ->
      func = args.shift()
      args.push ->
        results[i] = arguments
        done(results)
      func.apply context, args
    array.asyncParForEach tasks, iterFn, fn
    tasks

  ## Exports
  isFunction: isFunction
