kopi.module("kopi.exceptions")
  .define (exports) ->

    ###
    异常的基类
    ###
    class Exception extends Error
      constructor: (message="") ->
        this.name = this.constructor.name
        this.message = message

    ###
    方法未实现
    ###
    class NotImplementedError extends Exception
      constructor: (message="Not implemented yet.") ->
        super

    ###
    数值错误
    ###
    class ValueError extends Exception

    exports.Exception = Exception
    exports.NotImplementedError = NotImplementedError
    exports.ValueError = ValueError
