kopi.module("kopi.views")
  .define (exports) ->
    ###
    View 的基类

    ###
    class View

      constructor: (path, args=[]) ->
        throw new Error("Missing path") unless path?
        this.path = path
        this.args = args

    exports.View = View
