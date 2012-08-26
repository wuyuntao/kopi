# Array utilities

This module provides useful functional helpers for `Array`. It delegates
to built-in functions, if present, using the native implementations of
`forEach`, `map`, `indexOf`.

You can access the module by doing:

```coffeescript
array = require "kopi/utils/array"
```


## clone(array)

Create a shallow-copied clone of the `array`. Any nested objects
or arrays will be copied by reference, not duplicated.

```coffeescript
# return: [1, 2, 3]
array.clone [1, 2, 3]
```

## empty(array)

Remove all objects from the `array`.

```coffeescript
# return: []
array.empty [1, 2, 3]
```


## fill(array, value[, count])

Fill the `array` with the specific `value`. if `count` (defaults
to `array.length`) is not given it will fill the entire array.

```coffeescript
# return: [1, 1, 1]
array.fill [], 1, 3

# return: [1, 1, 1]
array.fill [0, 0, 0], 2
```


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


## indexOf(array, item)

Returns the index at which `item` can be found in the array,
or `-1` if `item` is not found. Uses the native `indexOf` function
if available.

```coffeescript
# return: 1
array.indexOf [1, 2, 3], 2
```


## has(array, item)

Does the `array` contain the given `item`?

```coffeescript
# return: true
array.has [1, 2, 3], 2
```


## insertAt(array, item[, index])

Insert an `item` into the `array` at a given `index` (defaults to 0).

```coffeescript
# return [1, 2, 4, 3]
array.insertAt [1, 2, 3], 4, 2
```


## isArray(array)

Returns true if `array` is an `Array`. Uses native `Array.isArray`
function if available.


## isEmpty(array)

Returns true if `array` does not contain any item.

## map(array, iterator, context)

Return the results of applying the iterator to each element.

Delegates to **ECMAScript 5**'s native `map` if available.

```coffeescript
# return: [2, 4, 6]
array.map [1, 2, 3], (n) -> 2 * n
```


## random(array)

Return a random item from `array`.

```coffeescript
# return: 1 or 2 or 3
array.choice [1,2,3]
```


## remove(array, item)

Remove the given `item` from `array`. Returns `true` if
`item` is removed.

```coffeescript
# return: true
# array: [1, 3]
array.remove [1, 2, 3], 2
```


## removeAt(array, index)

Remove the item at the given `index` from `array`. Returns `true`
if item is removed.

```coffeescript
# return: true
# array: ["a", "b"]
array.removeAt ["a", "b", "c"], 2
```


## unique(array[, comparer])

Removes duplicates from an array.

`comparer` is a function to generate keys for items in the `array`
and test item equality. By default, it compares items by
their types and string presentation, or guid if available.

```coffeescript
# return: [1, 2, "a", 3]
array.unique [1, 2, "a", 2, "a", 3]

```


