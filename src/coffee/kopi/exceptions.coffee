kopi.module("kopi.exceptions")
  .define (exports) ->

    ###
    异常的基类
    ###
    class Exception extends Error
      constructor: (message) ->
        super("#{this.constructor.name}: #{message}")

    exports.Exception = Exception
