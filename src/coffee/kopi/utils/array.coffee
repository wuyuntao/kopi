define "kopi/utils/array", (require, exports, module) ->

  exceptions = require "kopi/exceptions"
  utils = require "kopi/utils"

  math = Math

  # Establish the object that gets thrown to break out of a loop iteration.
  # `StopIteration` is SOP on Mozilla.
  breaker = if typeof(StopIteration) is 'undefined' then '__break__' else StopIteration

  ArrayProto = Array.prototype

  count = (array, iterator, context) ->
    n = 0
    for v, i in array
      n += 1 if iterator.call context, v, i
    n

  empty = (array) -> array.length = 0

  fill = (value, count) ->
    if count == 0 then [] else (value for i in [0...count])

  forEach = (array, iterator, context) ->
    try
      iterator.call(context, v, i, array) for v, i in array
    catch e
      throw e if e isnt breaker
    array

  ###
  Asynchronous sequential version of Array.prototype.forEach

  @param  {Array}     array     the array to iterate over
  @param  {Function}  iterator  the function to apply to each item in the array,
                                function has three argument, the first is the item
                                value, the second is the item index, the third is
                                a callback function
  @param  {Function}  fn        the function to call when the forEach has ended
  ###
  asyncForEach = (array, iterator, fn, context) ->
    len = array.length
    loopFn = ->
      v = array.pop()
      i = len - array.length - 1
      iterator.call(context, v, i, doneFn, array)
    doneFn = (error, result) ->
      if array.length > 0 then loopFn() else (fn(error, result) if fn)
    doneFn()
    array

  ###
  Asynchronous parallel version of Array.prototype.forEach

  @param  {Array}     array     the array to iterate over
  @param  {Function}  iterator  the function to apply to each item in the array,
                                function has three argument, the first is the item
                                value, the second is the item index, the third is
                                a callback function
  @param  {Function}  fn        the function to call when the forEach has ended
  ###
  asyncParForEach = (array, iterator, fn, context) ->
    done = 0
    len = array.length
    fn() if array.length == 0
    doneFn = (error, result) ->
      done++
      fn(error, result) if done == len and fn
    try
      iterator.call(context, v, i, doneFn, array) for v, i in array
    catch e
      throw e if e isnt breaker
    array

  if ArrayProto.indexOf
    indexOf = (array, obj) ->
      ArrayProto.indexOf.call(array, obj)
  else
    indexOf = (array, obj) ->
      for v, i in array
        return i if v == obj
      -1

  has = (array, obj) ->
    indexOf(array, obj) != -1

  insertAt = (array, index, obj) ->
    array.splice(index, 0, obj)

  isArray = Array.isArray or= (array) ->
    !!(array and array.concat and array.unshift and not array.callee)

  isEmpty = (array) -> array.length == 0

  last = (array) -> if array.length > 0 then array[array.length - 1] else undefined

  map = (array, iterator, context) ->
    results = []
    forEach array, (v, i) ->
      array[i] = iteration.call(context, v, i, array)
    results

  ###
  Pick a random item from array

  TODO Pick more than one item from array?

  @param  {Array}     array
  @return {Object}    A random item in array
  ###
  random = (array) ->
    if array.length > 1 then array[math.floor(math.random() * array.length)] else array[0]

  remove = (array, obj) ->
    i = indexOf(array, obj)
    if i >= 0 then removeAt(array, obj) else false

  removeAt = (array, i) ->
    ArrayProto.splice.call(array, i, 1).length == 1

  rotate = (array, reverse=false) ->
    if reverse
      obj = array.shift()
      array.push(obj)
    else
      obj = array.pop()
      array.unshift(obj)
    obj

  ###
  求和

  @param  {Array}     array     数组
  @param  {Function}  iterator    求和函数
  @return {Object}              求和结果
  ###
  sum = (array, iterator, conext) ->
    s = 0
    for item, i in array
      s += if iterator? then iterator.call(context, item, i) else item
    s

  ###
  求平均

  @param  {Array}     array     数组
  @param  {Function}  iterator    求平均函数
  @return {Object}              求平均结果
  ###
  average = (array, iterator, context) ->
    sum(array, iterator, context) / array.length

  ###
  Removes duplicates from an array

  @param  {Array}     array
  @param  {Function}  comparer decides how items are considered duplicate
  ###
  simpleKeyFn = (item) -> (typeof item).charAt(0) + (item.guid or item)
  unique = (array, keyFn=simpleKeyFn) ->
    set = []
    hash = {}
    for item, i in array
      key = keyFn(item)
      unless key of hash
        hash[key] = true
        set.push(item)
    set

  ArrayProto: ArrayProto
  count: count
  forEach: forEach
  asyncForEach: asyncForEach
  asyncParForEach: asyncParForEach
  empty: empty
  fill: fill
  indexOf: indexOf
  has: has
  insertAt: insertAt
  isArray: isArray
  isEmpty: isEmpty
  last: last
  map: map
  random: random
  remove: remove
  removeAt: removeAt
  rotate: rotate
  sum: sum
  average: average
  unique: unique
