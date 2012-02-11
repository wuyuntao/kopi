kopi.module("kopi.utils.structs.weakmap")
  .define (exports) ->

    ###
    WeakMaps are key/value maps in which keys are objects.

    ###
    class WeakMap

      constructor: ->
        this.keys = []
        this.values = []

      ###
      Returns the value associated to the key object, defaultValue if there is none.
      ###
      get: (key, defaultValue) ->
        i = this.keys.indexOf(key)
        if i < 0 then defaultValue else this.values[i]

      ###
      Set the value for the key object in WeakMap
      ###
      set: (key, value) ->
        i = this.keys.indexOf(key)
        i = this.keys.length if i < 0
        this.keys[i] = key
        this.values[i] = value
        this

      ###
      Returns a boolean asserting whether a value has been associated to the key object
      in WeakMap or not
      ###
      has: (key) -> this.keys.indexOf(key) >= 0

      ###
      Removes any value associated to the key object. After such a call, WeakMap.has(key)
      will return false.
      ###
      remove: (key) ->
        i = this.keys.indexOf(key)
        if i >= 0
          this.keys.splice(i, 1)
          this.values.splice(i, 1)
          true
        else
          false

      ###
      Iterate over the map
      ###
      forEach: (iterator) ->
        if iterator
          for key, i in this.keys
            value = this.values[i]
            iterator.call(this, key, value)
        this

    exports.WeakMap = WeakMap
