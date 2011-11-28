kopi.module("kopi.db.adapters.kv")
  .require("kopi.utils.text")
  .require("kopi.db.adapters.client")
  .define (exports, text, client) ->

    ###
    Adapter for Key/Value Databases like local storage, memcached, redis, etc.

    Model definition

      class app.user.User extends Model
        cls = this
        cls.fields
          sid:
            type: Model.INTEGER
            primary: true
          login:
            type: Model.STRING
            index: true
          avatar:
            type: Model.STRING

    Data Structure

      == key ==                   == value ==
      kopi:user:1                 {"sid":1,"login":"kobe","avatar":null}
      kopi:user:2                 {"sid":2,"login":"kd35","avatar":"/avatars/kd35.jpg"}
      kopi:user:index:pk          {"1":1,"2":2}
      kopi:user:index:login       {"kopi":1,"kd35":2}

    NOTE
      Key/Value adapter does not support multiple fields querying
      Key/Value adapter does not support non-unique index
    ###
    class KeyValueAdapter extends client.ClientAdapter

      this.configure
        keyPrefix: "kopi"
        keyDelimiter: ":"

      create: (query, fn) ->

      retrieve: (query, fn) ->

      update: (query, fn) ->

      destroy: (query, fn) ->

      ###
      Build key for model instance
      ###
      _modelKey: (model, pk) ->
        self = this
        unless self._modelKeyTmpl
          prefix = self._options.keyPrefix
          delimiter = self._options.delimiter
          self._modelKeyTmpl = "#{prefix}#{delimiter}{model}#{delimiter}#{pk}"
        text.format(self._modelKeyTmpl, model: model, pk: pk)

      ###
      Build key for model index
      ###
      _indexKey: (model, index="pk") ->
        self = this
        unless self._indexKeyTmpl
          prefix = self._options.keyPrefix
          delimiter = self._options.delimiter
          self._indexKeyTmpl = "#{prefix}#{delimiter}{model}#{delimiter}index#{delimiter}{index}"
        text.format(self._modelKeyTmpl, model: model, index: index)

      ###
      Get value from db. Implement in subclasses
      ###
      _get: (key, value) ->
        throw new exceptions.NotImplementedError()

      ###
      Set value to db. Implement in subclasses
      ###
      _set: (key, value) ->
        throw new exceptions.NotImplementedError()

    exports.KeyValueAdapter = KeyValueAdapter
