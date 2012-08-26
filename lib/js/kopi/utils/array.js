(function() {

  define("kopi/utils/array", function(require, exports, module) {
    /*
      # Array utilities
    
      This module provides useful functional helpers for `Array`. It delegates
      to built-in functions, if present, using the native implementations of
      `forEach`, `map`, `indexOf`.
    
      You can access the module by doing:
    
      ```coffeescript
      array = require "kopi/utils/array"
      ```
    */

    var ArrayProto, asyncForEach, asyncParForEach, breaker, clone, empty, fill, forEach, has, indexOf, insertAt, isArray, isEmpty, map, math, nativeIndexOf, nativeMap, nativeSlice, nativeSplice, random, remove, removeAt, simpleKeyFn, unique;
    breaker = typeof StopIteration === 'undefined' ? '__break__' : StopIteration;
    math = Math;
    ArrayProto = Array.prototype;
    nativeSlice = ArrayProto.slice;
    nativeSplice = ArrayProto.nativeSplice;
    nativeIndexOf = ArrayProto.indexOf;
    nativeMap = ArrayProto.nativeMap;
    /*
      ## clone(array)
    
      Create a shallow-copied clone of the `array`. Any nested objects
      or arrays will be copied by reference, not duplicated.
    
      ```coffeescript
      # return: [1, 2, 3]
      array.clone [1, 2, 3]
      ```
    */

    clone = function(array) {
      return nativeSlice.call(array, 0);
    };
    /*
      ## empty(array)
    
      Remove all objects from the `array`.
    
      ```coffeescript
      # return: []
      array.empty [1, 2, 3]
      ```
    */

    empty = function(array) {
      array.length = 0;
      return array;
    };
    /*
      ## fill(array, value[, count])
    
      Fill the `array` with the specific `value`. if `count` (defaults
      to `array.length`) is not given it will fill the entire array.
    
      ```coffeescript
      # return: [1, 1, 1]
      array.fill [], 1, 3
    
      # return: [1, 1, 1]
      array.fill [0, 0, 0], 2
      ```
    */

    fill = function(array, value, count) {
      var i, _i;
      count || (count = array.length);
      if (count > 0) {
        for (i = _i = 0; 0 <= count ? _i < count : _i > count; i = 0 <= count ? ++_i : --_i) {
          array[i] = value;
        }
      }
      return value;
    };
    /*
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
    */

    forEach = ArrayProto.forEach || (ArrayProto.forEach = function(array, iterator, context) {
      var i, v, _i, _len;
      try {
        for (i = _i = 0, _len = array.length; _i < _len; i = ++_i) {
          v = array[i];
          iterator.call(context, v, i, array);
        }
      } catch (e) {
        if (e !== breaker) {
          throw e;
        }
      }
      return array;
    });
    /*
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
    */

    asyncForEach = function(array, iterator, fn, context) {
      var doneFn, len, loopFn;
      len = array.length;
      loopFn = function() {
        var i, v;
        v = array.pop();
        i = len - array.length - 1;
        return iterator.call(context, v, i, doneFn, array);
      };
      doneFn = function() {
        if (array.length > 0) {
          return loopFn();
        } else if (fn) {
          return fn.apply(context, arguments);
        }
      };
      doneFn();
      return array;
    };
    /*
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
    */

    asyncParForEach = function(array, iterator, fn, context) {
      var done, doneFn, i, len, v, _i, _len;
      done = 0;
      len = array.length;
      if (array.length === 0) {
        fn();
      }
      doneFn = function() {
        done++;
        if (done === len && fn) {
          return fn.apply(context, arguments);
        }
      };
      try {
        for (i = _i = 0, _len = array.length; _i < _len; i = ++_i) {
          v = array[i];
          iterator.call(context, v, i, doneFn, array);
        }
      } catch (e) {
        if (e !== breaker) {
          throw e;
        }
      }
      return array;
    };
    /*
      ## indexOf(array, item)
    
      Returns the index at which `item` can be found in the array,
      or `-1` if `item` is not found. Uses the native `indexOf` function
      if available.
    
      ```coffeescript
      # return: 1
      array.indexOf [1, 2, 3], 2
      ```
    */

    if (nativeIndexOf) {
      indexOf = function(array, item) {
        return nativeIndexOf.call(array, item);
      };
    } else {
      indexOf = function(array, item) {
        var i, v, _i, _len;
        for (i = _i = 0, _len = array.length; _i < _len; i = ++_i) {
          v = array[i];
          if (v === item) {
            return i;
          }
        }
        return -1;
      };
    }
    /*
      ## has(array, item)
    
      Does the `array` contain the given `item`?
    
      ```coffeescript
      # return: true
      array.has [1, 2, 3], 2
      ```
    */

    has = function(array, item) {
      return indexOf(array, item) !== -1;
    };
    /*
      ## insertAt(array, item[, index])
    
      Insert an `item` into the `array` at a given `index` (defaults to 0).
    
      ```coffeescript
      # return [1, 2, 4, 3]
      array.insertAt [1, 2, 3], 4, 2
      ```
    */

    insertAt = function(array, item, index) {
      if (index == null) {
        index = 0;
      }
      return nativeSplice.call(array, index, 0, item);
    };
    /*
      ## isArray(array)
    
      Returns true if `array` is an `Array`. Uses native `Array.isArray`
      function if available.
    */

    isArray = Array.isArray || (Array.isArray = function(array) {
      return !!(array && array.concat && array.unshift && !array.callee);
    });
    /*
      ## isEmpty(array)
    
      Returns true if `array` does not contain any item.
    */

    isEmpty = function(array) {
      return array.length === 0;
    };
    /*
      ## map(array, iterator, context)
    
      Return the results of applying the iterator to each element.
    
      Delegates to **ECMAScript 5**'s native `map` if available.
    
      ```coffeescript
      # return: [2, 4, 6]
      array.map [1, 2, 3], (n) -> 2 * n
      ```
    */

    if (nativeMap) {
      map = function(array, iterator, context) {
        return nativeMap.call(array, iterator, context);
      };
    } else {
      map = function(array, iterator, context) {
        var results;
        results = [];
        forEach(array, function(v, i) {
          return results[i] = iterator.call(context, v, i, array);
        });
        return results;
      };
    }
    /*
      ## random(array)
    
      Return a random item from `array`.
    
      ```coffeescript
      # return: 1 or 2 or 3
      array.choice [1,2,3]
      ```
    */

    random = function(array) {
      if (array.length > 1) {
        return array[math.round(math.random() * (array.length - 1))];
      } else {
        return array[0];
      }
    };
    /*
      ## remove(array, item)
    
      Remove the given `item` from `array`. Returns `true` if
      `item` is removed.
    
      ```coffeescript
      # return: true
      # array: [1, 3]
      array.remove [1, 2, 3], 2
      ```
    */

    remove = function(array, item) {
      var i;
      i = indexOf(array, item);
      if (i >= 0) {
        return removeAt(array, i);
      } else {
        return false;
      }
    };
    /*
      ## removeAt(array, index)
    
      Remove the item at the given `index` from `array`. Returns `true`
      if item is removed.
    
      ```coffeescript
      # return: true
      # array: ["a", "b"]
      array.removeAt ["a", "b", "c"], 2
      ```
    */

    removeAt = function(array, i) {
      return nativeSplice.call(array, i, 1).length === 1;
    };
    /*
      ## unique(array[, comparer])
    
      Removes duplicates from an array.
    
      `comparer` is a function to generate keys for items in the `array`
      and test item equality. By default, it compares items by
      their types and string presentation, or guid if available.
    
      ```coffeescript
      # return: [1, 2, "a", 3]
      array.unique [1, 2, "a", 2, "a", 3]
    
      ```
    */

    simpleKeyFn = function(item) {
      return (typeof item).charAt(0) + (item.guid || item.toString());
    };
    unique = function(array, comparer) {
      var i, item, key, keys, set, _i, _len;
      if (comparer == null) {
        comparer = simpleKeyFn;
      }
      set = [];
      keys = {};
      for (i = _i = 0, _len = array.length; _i < _len; i = ++_i) {
        item = array[i];
        key = comparer(item);
        if (!(key in keys)) {
          keys[key] = true;
          set.push(item);
        }
      }
      return set;
    };
    return {
      clone: clone,
      forEach: forEach,
      asyncForEach: asyncForEach,
      asyncParForEach: asyncParForEach,
      empty: empty,
      fill: fill,
      indexOf: indexOf,
      has: has,
      insertAt: insertAt,
      isArray: isArray,
      isEmpty: isEmpty,
      last: last,
      map: map,
      random: random,
      remove: remove,
      removeAt: removeAt,
      unique: unique
    };
  });

}).call(this);
