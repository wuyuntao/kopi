define "kopi/exceptions", (require, exports, module) ->

  ###
  Base class of all exceptions
  ###
  class Exception extends Error
    constructor: (message="") ->
      this.name = this.constructor.name
      this.message = message

  ###
  Error raised when HTML element can not be found
  ###
  class NoSuchElementError extends Exception
    constructor: (element) ->
      message = "Can not find element: #{element}"
      super(message)

  ###
  Error raised when a method is not ready to use
  ###
  class NotImplementedError extends Exception
    constructor: (message="Not implemented yet.") ->
      super(message)

  ###
  Error raised when value is not correct
  ###
  class ValueError extends Exception

  ###
  Error raised when a singleton class initialized more than once.
  ###
  class SingletonError extends Exception
    constructor: (klass) ->
      super("#{klass.name} is a singleton class.")

  Exception: Exception
  NoSuchElementError: NoSuchElementError
  NotImplementedError: NotImplementedError
  ValueError: ValueError
  SingletonError: SingletonError
