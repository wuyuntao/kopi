kopi.module("kopi.utils.number")
  .define (exports) ->

    isNumber = (number) ->
      (obj is +obj) or Object.toString.call(obj) is '[object Number]'

    range = (start, stop, step=1) ->
      step *= -1 if start < stop and step > 0
      (i for i in [start...stop] by step)

    threshold = (value, min, max) ->
      value = max if max isnt null and value > max
      value = min if min isnt null and value < min
      value

    exports.isNumber = isNumber
    exports.range = range
    exports.threshold = threshold
