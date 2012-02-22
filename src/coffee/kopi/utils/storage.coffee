define "kopi/utils/storage", (require, exports, module) ->

  ###
  A storage interface for browsers does not support WebStorage
  ###
  class MemoryStorage

    constructor: ->
      this._keys = []
      this._values = {}

    length: -> this._keys.length

    key: (index) -> this._keys[index]

    getItem: (key) -> this._values[key]

    setItem: (key, value) ->
      this._keys.push(key) if not key in this._keys
      this._values[key] = value
      return

    removeItem: (key) ->
      this._keys.splice(this._keys.indexOf(key), 1)
      this._values[key] = undefined
      return

    clear: ->
      this._keys = []
      this._values = {}
      return

  memoryStorage: new MemoryStorage()
