###!
Some common exceptions for Kopi

@author Wu Yuntao <wyt.brandon@gmail.com>
@license MIT

###
define "kopi/exceptions", (require, exports, module) ->

  ###
  Base class of all exceptions.

  @class
  ###
  class Exception extends Error
    ###
    @constructor
    @param {String} message
    ###
    constructor: (message="") ->
      this.name = this.constructor.name
      this.message = message

  ###
  Error raised when HTML element can not be found.

  @class
  ###
  class NoSuchElementError extends Exception
    ###
    @constructor
    @param {Element} element
    ###
    constructor: (element) ->
      message = "Can not find element: #{element}"
      super(message)

  ###
  Error raised when a method is not ready to use.

  @class
  ###
  class NotImplementedError extends Exception
    ###
    @constructor
    @param {String} message
    ###
    constructor: (message="Not implemented yet.") ->
      super(message)

  ###
  Error raised when value is not correct.

  @class
  ###
  class ValueError extends Exception

  ###
  Error raised when a singleton class initialized more than once.

  @class
  ###
  class SingletonError extends Exception
    ###
    @constructor
    @param {Class} klass
    ###
    constructor: (klass) ->
      super("#{klass.name} is a singleton class.")

  ###!
  Exports exceptions
  ###
  Exception: Exception
  NoSuchElementError: NoSuchElementError
  NotImplementedError: NotImplementedError
  ValueError: ValueError
  SingletonError: SingletonError
