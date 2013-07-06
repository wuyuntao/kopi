define "kopi/exceptions", (require, exports, module) ->

  ###
  # Some common exceptions for Kopi

  ## Exception

  Base class of all exceptions.

  ```coffeescript
  throw new Exception("Some exception")
  ```

  ###
  class Exception extends Error

    constructor: (message="") ->
      this.name = this.constructor.name or "Error"
      this.message = message

  ###
  ## NoSuchElementError

  Error raised when HTML element can not be found.

  ```coffeescript
  element = $("#container")
  throw new NoSuchElementError(element) unless element.length
  ```

  ###
  class NoSuchElementError extends Exception

    constructor: (element) ->
      message = "Can not find element: #{element}"
      super(message)

  ###
  ## NotImplementedError

  Error raised when a method is not ready to use.

  ###
  class NotImplementedError extends Exception

    constructor: (message="Not implemented yet.") ->
      super(message)

  ###
  ## ValueError

  Error raised when value is not correct.

  ###
  class ValueError extends Exception

  ###
  ## SingletonError

  Error raised when a singleton class initialized more than once.

  ```coffeescript
  class Viewport

    # Reference of singleton instance
    this.instance = null

    constructor: ->
      cls = this.constructor
      throw new SingletonError(cls) if cls.instance
      cls.instance = this
  ```
  ###
  class SingletonError extends Exception

    constructor: (klass) ->
      super("#{klass.name} is a singleton class.")

  Exception: Exception
  NoSuchElementError: NoSuchElementError
  NotImplementedError: NotImplementedError
  ValueError: ValueError
  SingletonError: SingletonError
