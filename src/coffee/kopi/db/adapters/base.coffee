kopi.module("kopi.db.adapters.base")
  .require("kopi.exceptions")
  .require("kopi.utils.klass")
  .require("kopi.db.queries")
  .define (exports, exceptions, klass, queries) ->

    class BaseAdapter

      cls = this
      klass.configure cls

      cls.CREATE = "create"
      cls.RETRIEVE = "retrieve"
      cls.UPDATE = "update"
      cls.DESTROY = "destroy"
      cls.METHODS = [cls.CREATE, cls.RETRIEVE, cls.UPDATE, cls.DESTROY]

      constructor: (options={}) ->
        this.configure(options)

      ###
      Check if adapter is supported by browser
      ###
      support: (model) -> true

      # Define template methods of CRUD actions
      notImplementedFn = (query, fn) -> throw new exceptions.NotImplementedError()
      cls.prototype[method] = notImplementedFn for method in cls.METHODS

    exports.BaseAdapter = BaseAdapter
