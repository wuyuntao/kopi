define "kopi/db/adapters/kv", (require, exports, module) ->

  text = require "kopi/utils/text"
  object = require "kopi/utils/object"
  client = require "kopi/db/adapters/client"

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
      pk = query.pk()
      if not pk
        fn(true, "Must provide primary key") if fn
        return self
      key = self._keyForModel(model, pk)
      isKeyExists = !!self._get(key)
      if isKeyExists
        fn(true, "Primary key already exists.") if fn
        return self
      self._set(key, self._adapterObject(attrs, model.meta().names))
      fn(null) if fn
      self

    retrieve: (query, fn) ->
      self = this
      model = query.model
      pk = query.pk()
      if not pk
        fn("Must provide primary key") if fn
        return self
      key = self._keyForModel(model, pk)
      value = self._get(key)
      if value
        try
          fn(null, [self._modelObject(value, model.meta().names)]) if fn
        catch e
          fn("Failed to parse value: #{e}") if fn
      else
        fn(null, []) if fn
      fn(message.error, message) if fn
      self

    update: (query, fn) ->
      self = this
      retrieveFn = (error, message) ->
        if error
          fn(error, message) if fn
          return
        model = query.model
        key = self._keyForModel(model, query.pk())
        value = message.entries[0]
        if value
          object.extend value, query.attrs()
          self._set(key, self._adapterObject(value, model.meta().names))
          fn(null) if fn
        else
          fn(true, "Entry not found") if fn

      self.retrieve(query, retrieveFn)
      self

    destroy: (query, fn) ->
      self = this
      model = query.model
      pk = query.pk()
      if not pk
        fn(true, "pk not found") if fn
        return self
      key = self._keyForModel(model, pk)
      self._remove(key)
      fn(null) if fn
      self

    ###
    Build key for model instance
    ###
    _keyForModel: (model, pk) ->
      self = this
      unless self._keyForModelTmpl
        prefix = self._options.keyPrefix
        delimiter = self._options.keyDelimiter
        self._keyForModelTmpl = "#{prefix}#{delimiter}{model}#{delimiter}#{pk}"
      text.format(self._keyForModelTmpl, model: text.dasherize(model.name), pk: pk)

    ###
    Build key for model index
    ###
    _keyForIndex: (model, index="pk") ->
      self = this
      unless self._keyForIndexTmpl
        prefix = self._options.keyPrefix
        delimiter = self._options.delimiter
        self._keyForIndexTmpl = "#{prefix}#{delimiter}{model}#{delimiter}index#{delimiter}{index}"
      text.format(self._keyForModelTmpl, model: model, index: index)

    ###
    Get value from db. Implement in subclasses
    ###
    _get: (store, key, value, fn) ->
      throw new exceptions.NotImplementedError()

    ###
    Set value to db. Implement in subclasses
    ###
    _set: (store, key, value, fn) ->
      throw new exceptions.NotImplementedError()

    ###
    Remove value from db. Implement in subclasses
    ###
    _remove: (store, key, fn) ->
      throw new exceptions.NotImplementedError()

  KeyValueAdapter: KeyValueAdapter
