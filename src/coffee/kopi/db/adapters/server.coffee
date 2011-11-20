kopi.module("kopi.db.adapters.server")
  .require("kopi.db.adapters.base")
  .define (exports, base) ->

    class ServerAdapter extends base.BaseAdapter

      cls = this
      cls.configure
        whereParam: "where"
        sortParam: "sort"
        skipParam: "skip"
        limitParam: "limit"
        # createURL: undefined
        # retrieveURL: undefined
        # updateURL: undefined
        # destroyURL: undefined

      defineMethod = (method) ->
        cls.prototype[method] = ->
          this._send(arguments...)
      for method in cls.METHODS
        defineMethod(method)

    exports.ServerAdapter = ServerAdapter
