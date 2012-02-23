define "kopi/utils/structs/weakmap", (require, exports, module) ->

  ###
  WeakMaps are key/value maps in which keys are objects.

  ###
  class WeakMap

    constructor: ->
      this._keys = []
      this._values = []

    ###
    Returns the value associated to the key object, defaultValue if there is none.
    ###
    get: (key, defaultValue) ->
      i = this._keys.indexOf(key)
      if i < 0 then defaultValue else this._values[i]

    ###
    Set the value for the key object in WeakMap
    ###
    set: (key, value) ->
      i = this._keys.indexOf(key)
      i = this._keys.length if i < 0
      this._keys[i] = key
      this._values[i] = value
      this

    ###
    Returns a boolean asserting whether a value has been associated to the key object
    in WeakMap or not
    ###
    has: (key) -> this._keys.indexOf(key) >= 0

    ###
    Removes any value associated to the key object. After such a call, WeakMap.has(key)
    will return false.
    ###
    remove: (key) ->
      i = this._keys.indexOf(key)
      if i >= 0
        this._keys.splice(i, 1)
        this._values.splice(i, 1)
        true
      else
        false

    ###
    Iterate over the map
    ###
    forEach: (iterator) ->
      if iterator
        for key, i in this._keys
          value = this._values[i]
          iterator.call(this, key, value)
      this

  WeakMap: WeakMap
