define "kopi/db/adapters/base", (require, exports, module) ->

  exceptions = require "kopi/exceptions"
  klass = require "kopi/utils/klass"
  models = require "kopi/db/models"
  queries = require "kopi/db/queries"

  ###
  Interface for adapters provides for five methods
  `create`, `retrieve`, `update`, `destroy` and `raw`

  ###
  class BaseAdapter

    kls = this
    klass.configure kls

    kls.CREATE = "create"
    kls.RETRIEVE = "retrieve"
    kls.UPDATE = "update"
    kls.DESTROY = "destroy"
    kls.RAW = "raw"
    kls.ACTIONS = [kls.CREATE, kls.RETRIEVE, kls.UPDATE, kls.DESTROY, kls.RAW]

    ###
    Check if adapter is supported by browser
    ###
    this.support = (model) -> true

    constructor: (options={}) ->
      this.configure(options)

    init: (model, fn) -> this

    _adapterObject: (obj, fields) ->
      self = this
      if fields
        for own key, field of fields
          obj[key] = field.default if typeof obj[key] is 'undefined'
        obj[key] = self._adapterValue(obj[key], field)
      obj

    _modelObject: (obj, fields) ->
      self = this
      if fields
        for own key, field of fields
          obj[key] = field.default if typeof obj[key] is 'undefined'
        obj[key] = self._modelValue(obj[key], field)
      obj

    ###
    Convert model value to adapter value.
    Could be overriden for specific adapter.
    ###
    _adapterValue: (value, field) ->
      this._forceType(value, field)

    ###
    Convert adapter value to model value.
    Could be overriden for specific adapter.
    ###
    _modelValue: (value, field) ->
      this._forceType(value, field)

    ###
    Force type conversion for field value
    ###
    _forceType: (value, field) ->
      return value unless field and field.type
      switch field.type
        when models.INTEGER
          parseInt(value)
        when models.STRING, models.TEXT
          value + ""
        when models.FLOAT
          parseFloat(value)
        else
          value

    # Define template methods of CRUD actions
    proto = kls.prototype
    notImplementedFn = -> throw new exceptions.NotImplementedError()
    proto[action] = notImplementedFn for action in kls.ACTIONS

  BaseAdapter: BaseAdapter
