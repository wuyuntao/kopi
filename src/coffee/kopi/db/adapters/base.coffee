kopi.module("kopi.db.adapters.base")
  .require("kopi.exceptions")
  .require("kopi.utils.klass")
  .require("kopi.db.models")
  .require("kopi.db.queries")
  .define (exports, exceptions, klass, models, queries) ->

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

    exports.BaseAdapter = BaseAdapter
