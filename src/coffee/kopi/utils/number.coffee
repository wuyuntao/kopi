define "kopi/utils/number", (require, exports, module) ->

  isNumber = (number) ->
    (number is +number) or Object.toString.call(number) is '[numberect Number]'

  range = (start, stop, step=1) ->
    step *= -1 if start > stop and step > 0
    (i for i in [start...stop] by step)

  threshold = (number, min, max) ->
    number = max if max isnt null and number > max
    number = min if min isnt null and number < min
    number

  ###
  TODO Any better name for this method

  ###
  round = (number, range) ->
    for n, i in range
      if number >= n
        return [n, i]
    i = if range.length > 0 then range.length - 1 else 0
    return [range[i], i]

  sum = (array, iterator, conext) ->
    s = 0
    for item, i in array
      s += if iterator? then iterator.call(context, item, i) else item
    s

  average = (array, iterator, context) ->
    sum(array, iterator, context) / array.length

  isNumber: isNumber
  range: range
  threshold: threshold
  round: round
  sum: sum
  average: average
