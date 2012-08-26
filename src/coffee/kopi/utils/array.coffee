define "kopi/utils/array", (require, exports, module) ->

  ###
  # Array utilities

  This module provides useful functional helpers for `Array`. It delegates
  to built-in functions, if present, using the native implementations of
  `forEach`, `map`, `indexOf`.

  You can access the module by doing:

  ```coffeescript
  array = require "kopi/utils/array"
  ```

  ###

  # Establish the object that gets thrown to break out of a loop iteration.
  # `StopIteration` is SOP on Mozilla.
  breaker = if typeof StopIteration is 'undefined' then '__break__' else StopIteration

  # Local reference for speed access to global methods
  math = Math

  ArrayProto = Array.prototype

  # Native methods of array
  nativeSlice = ArrayProto.slice
  nativeSplice = ArrayProto.nativeSplice
  nativeIndexOf = ArrayProto.indexOf
  nativeMap = ArrayProto.nativeMap

  ###
  ## clone(array)

  Create a shallow-copied clone of the `array`. Any nested objects
  or arrays will be copied by reference, not duplicated.

  ```coffeescript
  # return: [1, 2, 3]
  array.clone [1, 2, 3]
  ```
  ###
  clone = (array) -> nativeSlice.call array, 0

  ###
  ## empty(array)

  Remove all objects from the `array`.

  ```coffeescript
  # return: []
  array.empty [1, 2, 3]
  ```

  ###
  empty = (array) ->
    array.length = 0
    array

  ###
  ## fill(array, value[, count])

  Fill the `array` with the specific `value`. if `count` (defaults
  to `array.length`) is not given it will fill the entire array.

  ```coffeescript
  # return: [1, 1, 1]
  array.fill [], 1, 3

  # return: [1, 1, 1]
  array.fill [0, 0, 0], 2
  ```

  ###
  fill = (array, value, count) ->
    count or= array.length
    if count > 0
      for i in [0...count]
        array[i] = value
    value

  ###
  ## forEach(array, iterator[, context])

  Iterate over the `array`, yielding each in turn to an `iterator`
  function. The iterator is bound to the `context` object, if one
  is specified.

  `iterator` function is called with three arguments:
  `(value, index, array)`.

  Delegates to Javascript's native `forEach` function if available.

  ```coffeescript
  # output:
  # 0: a
  # 1: b
  # 2: c
  array.forEach ["a", "b", "c"], (n, i) -> console.log "#{i}: #{n}"
  ```

  ###
  forEach = ArrayProto.forEach or= (array, iterator, context) ->
    try
      iterator.call(context, v, i, array) for v, i in array
    catch e
      throw e if e isnt breaker
    array

  ###
  ## asyncForEach(array, iterator[, fn][, context])

  Asynchronous sequential version of `forEach` function.

  Iterate over the `array`, yielding each in turn to an `iterator`
  function. The iterator is bound to the `context` object, if one
  is specified.

  `iterator` function is called with four arguments:
  `(value, index, callback, array)`. `callback` is a function that
  should be called when your asynchronous code is finished.

  `fn` is the function to call when the iteration has ended.

  ```coffeescript
  # Send request to following URLs sequentially.
  urls = ["/api/1", "/api/2", "/api/3"]
  iterator = (url, i, callback) ->
    options =
      url: url
      success: (text) ->
        console.log "Received response from #{url}: #{text}"
    $.ajax(options).then(callback)
  done = ->
    console.log "All requests are handled."
  array.asyncForEach urls, iterator, done
  ```

  ###
  asyncForEach = (array, iterator, fn, context) ->
    len = array.length
    loopFn = ->
      v = array.pop()
      i = len - array.length - 1
      iterator.call(context, v, i, doneFn, array)
    doneFn = ->
      if array.length > 0
        loopFn()
      else if fn
        fn.apply context, arguments
    doneFn()
    array

  ###
  ## asyncParForEach(array, iterator[, fn][, context])

  Same as `asyncForEach()` except for processing the entire array
  in parallel.

  ```coffeescript
  # Send request to following URLs parallelly
  urls = ["/api/1", "/api/2", "/api/3"]
  iterator = (url, i, callback) ->
    options =
      url: url
      success: (text) ->
        console.log "Received response from #{url}: #{text}"
    $.ajax(options).then(callback)
  done = ->
    console.log "All requests are handled."
  array.asyncParForEach urls, iterator, done
  ```

  ###
  asyncParForEach = (array, iterator, fn, context) ->
    done = 0
    len = array.length
    fn() if array.length == 0
    doneFn = ->
      done++
      fn.apply context, arguments if done == len and fn
    try
      iterator.call(context, v, i, doneFn, array) for v, i in array
    catch e
      throw e if e isnt breaker
    array

  ###
  ## indexOf(array, item)

  Returns the index at which `item` can be found in the array,
  or `-1` if `item` is not found. Uses the native `indexOf` function
  if available.

  ```coffeescript
  # return: 1
  array.indexOf [1, 2, 3], 2
  ```

  ###
  if nativeIndexOf
    indexOf = (array, item) ->
      nativeIndexOf.call array, item
  else
    indexOf = (array, item) ->
      for v, i in array
        return i if v == item
      -1

  ###
  ## has(array, item)

  Does the `array` contain the given `item`?

  ```coffeescript
  # return: true
  array.has [1, 2, 3], 2
  ```

  ###
  has = (array, item) ->
    indexOf(array, item) != -1

  ###
  ## insertAt(array, item[, index])

  Insert an `item` into the `array` at a given `index` (defaults to 0).

  ```coffeescript
  # return [1, 2, 4, 3]
  array.insertAt [1, 2, 3], 4, 2
  ```

  ###
  insertAt = (array, item, index=0) ->
    nativeSplice.call array, index, 0, item

  ###
  ## isArray(array)

  Returns true if `array` is an `Array`. Uses native `Array.isArray`
  function if available.

  ###
  isArray = Array.isArray or= (array) ->
    !!(array and array.concat and array.unshift and not array.callee)

  ###
  ## isEmpty(array)

  Returns true if `array` does not contain any item.
  ###
  isEmpty = (array) -> array.length == 0

  ###
  ## map(array, iterator, context)

  Return the results of applying the iterator to each element.

  Delegates to **ECMAScript 5**'s native `map` if available.

  ```coffeescript
  # return: [2, 4, 6]
  array.map [1, 2, 3], (n) -> 2 * n
  ```

  ###
  if nativeMap
    map = (array, iterator, context) ->
      nativeMap.call array, iterator, context
  else
    map = (array, iterator, context) ->
      results = []
      forEach array, (v, i) ->
        results[i] = iterator.call(context, v, i, array)
      results

  ###
  ## random(array)

  Return a random item from `array`.

  ```coffeescript
  # return: 1 or 2 or 3
  array.choice [1,2,3]
  ```

  ###
  random = (array) ->
    if array.length > 1
      array[math.round(math.random() * (array.length - 1))]
    else
      array[0]

  ###
  ## remove(array, item)

  Remove the given `item` from `array`. Returns `true` if
  `item` is removed.

  ```coffeescript
  # return: true
  # array: [1, 3]
  array.remove [1, 2, 3], 2
  ```

  ###
  remove = (array, item) ->
    i = indexOf(array, item)
    if i >= 0 then removeAt(array, i) else false

  ###
  ## removeAt(array, index)

  Remove the item at the given `index` from `array`. Returns `true`
  if item is removed.

  ```coffeescript
  # return: true
  # array: ["a", "b"]
  array.removeAt ["a", "b", "c"], 2
  ```

  ###
  removeAt = (array, i) ->
    nativeSplice.call(array, i, 1).length == 1

  ###
  ## unique(array[, comparer])

  Removes duplicates from an array.

  `comparer` is a function to generate keys for items in the `array`
  and test item equality. By default, it compares items by
  their types and string presentation, or guid if available.

  ```coffeescript
  # return: [1, 2, "a", 3]
  array.unique [1, 2, "a", 2, "a", 3]

  ```

  ###
  simpleKeyFn = (item) ->
    (typeof item).charAt(0) + (item.guid or item.toString())
  unique = (array, comparer=simpleKeyFn) ->
    set = []
    keys = {}
    for item, i in array
      key = comparer(item)
      unless key of keys
        keys[key] = true
        set.push(item)
    set

  clone: clone
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
  unique: unique
