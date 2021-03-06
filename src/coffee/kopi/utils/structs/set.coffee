define "kopi/utils/structs/set", (require, exports, module) ->

  map = require "kopi/utils/structs/map"

  class Set

    constructor: (set) ->
      this._map = new map.Map()
      this.add(item) for item in set if set

    has: (key) -> this._map.has(key)

    add: (key) ->
      this._map.set(key, true)

    remove: (key) ->
      this._map.remove(key)

    forEach: (iterator) ->
      self = this
      if iterator
        self._map.forEach (key) ->
          iterator.call(self, key)
      self

    length: -> this._map.length()

  Set: Set
