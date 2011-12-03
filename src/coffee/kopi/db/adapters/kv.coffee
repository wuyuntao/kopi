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
      kopi:user:index:login       {"kopi":1,"kd35":2}

    TODO
      Support non-pk fields querying
      support multiple fields querying
      support non-unique index
    ###
    class KeyValueAdapter extends client.ClientAdapter

      this.configure
        keyPrefix: "kopi"
        keyDelimiter: ":"

      create: (query, fn) ->
        self = this
        model = query.model
        attrs = query.attrs()
        pk = self._pk(query)
        pk = attrs[model.pkName()]
        key = self._modelKey(model, pk)
        self._set(key, self._stringify(attrs))
        message =
          ok: true
          pk: pk
        fn(null) if fn
        self

      retrieve: (query, fn) ->
        self = this
        model = query.model
        pk = query.pk()
        if not pk
          fn(true, "pk not found") if fn
          return self
        key = self._modelKey(model, pk)
        value = self._get(key)
        if value
          try
            value = self._parse(value)
            message =
              ok: true
              entry: value
          catch e
            message =
              error: true
              message: "Failed to parse: #{value}"
        else
          message =
            error: true
            message: "Can not find entry"
        fn(null, message) if fn
        self

      update: (query, fn) ->
        self = this
        retrieveFn = (error, message) ->
          if error
            fn(error, message) if fn
            return

          value = message.entry
          object.extend value, query.attrs()
          self._set(query.pk(), self._stringify(entry))

        self.retrieve(query, retrieveFn)
        self

      destroy: (query, fn) ->
        self = this
        model = query.model
        pk = query.pk()
        if not pk
          fn(true, "pk not found") if fn
          return self
        key = self._modelKey(model, pk)
        self._remove(key)
        fn(null) if fn
        self

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

      _remove: (key) ->
        throw new exceptions.NotImplementedError()

      ###
      Convert json to string.
      ###
      _stringify: (json) ->
        # TODO data processing
        JSON.stringify(json)

      _parse: (string) ->
        # TODO data processing
        JSON.parse(string)

    exports.KeyValueAdapter = KeyValueAdapter
