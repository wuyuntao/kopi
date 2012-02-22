define "kopi/exceptions", (require, exports, module) ->

  ###
  异常的基类
  ###
  class Exception extends Error
    constructor: (message="") ->
      this.name = this.constructor.name
      this.message = message

  ###
  Can not find element
  ###
  class NoSuchElementError extends Exception
    constructor: (element) ->
      message = "Can not find element: #{element}"
      super(message)

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

  class SingletonError extends Exception
    constructor: (klass) ->
      super("#{klass.name} is a singleton class. Can not be initialized twice.")

  Exception: Exception
  NoSuchElementError: NoSuchElementError
  NotImplementedError: NotImplementedError
  ValueError: ValueError
  SingletonError: SingletonError
