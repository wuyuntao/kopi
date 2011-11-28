kopi.module("kopi.db.adapters.base")
  .require("kopi.exceptions")
  .require("kopi.utils.klass")
  .require("kopi.db.queries")
  .define (exports, exceptions, klass, queries) ->

    class BaseAdapter

      kls = this
      klass.configure kls

      kls.CREATE = "create"
      kls.RETRIEVE = "retrieve"
      kls.UPDATE = "update"
      kls.DESTROY = "destroy"
      kls.ACTIONS = [kls.CREATE, kls.RETRIEVE, kls.UPDATE, kls.DESTROY]

      constructor: (options={}) ->
        this.configure(options)

      ###
      Check if adapter is supported by browser
      ###
      support: (model) -> true

      # Define template methods of CRUD actions
      proto = kls.prototype
      notImplementedFn = -> throw new exceptions.NotImplementedError()
      proto[action] = notImplementedFn for action in kls.ACTIONS

    exports.BaseAdapter = BaseAdapter
