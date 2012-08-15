###!
# A simple logging library that improve the original console
with timeline and custom tag support.

@author Wu Yuntao <wyt.brandon@gmail.com>
@license MIT

###

define "kopi/logging", (require, exports, module) ->

  array = require "kopi/utils/array"
  object = require "kopi/utils/object"
  settings = require "kopi/settings"
  exceptions = require "kopi/exceptions"

  class LoggerError extends exceptions.ValueError

  # Enumeration values of logger levels
  LOG = 0
  INFO = 1
  WARN = 2
  ERROR = 3

  NOOP_FN = -> false
  NOOP_FN.isNoop = true

  # @type  {Object} Store all loggers with their names
  loggers = {}
  # @type {Date}    Start time of logger
  startTime = (window.__KOPI__START_TIME or= new Date())
  # @type {Object}    Log timers
  timers = {}
  # @type {Object}    Log accumulators
  accumulators = {}
  # @type {Console} Local reference of console object
  console = null

  ###

  # Logger

  A simple logging library that improve the original console
  with timeline and custom tag support.

  ## Usage

  Just like `console`, a logger has 4 logging levels in a specific order

    LOG < INFO < WARN < ERROR

  You can update logging level on a logger at runtime.

  ## Instantiate a logger instance

    logging = require 'logging'

    # Get default logger
    logger = logging.logger()

    # Or use default logger directly
    logging.log "Say something"

    # Get a logger with a custom name
    logger = logging.logger('name_of_logger')

    # Get a logger with a custom name and high logging level
    logger = logging.logger 'name_of_logger',
      level: logging.ERROR

  Multiple calls to `logging.logger()` with the same name will always
  return a reference to the same `Logger` instance.

  ## Logging

  `Logger` has a similar interface to `console` object. But only following
  methods are supported: `log`, `info`, `warn`, `error`, `time`, `timeEnd`

    # output: [LOG] [0.027s] [kopi] log message [1, 2, 3]
    logger.log "log message", [1, 2, 3]

    # output: [INFO] [0.031s] [kopi] info message > Object
    logger.info "info message", key: 'value'

    # output: [WARN] [0.031s] [kopi] warn message Help!
    logger.warn "warn message", "Help!"

    # output: [ERROR] [0.031s] [kopi] error message > Error
    logger.error "error message", new Error("Something is Wrong")

    # output: [LOG] [0.034s] [kopi] time started
    logger.time "prof"

    # output [LOG] [1.035s] [kopi] time stoped. spent 1001ms.
    logger.timeEnd "prof"

  ## Changing level of logging

  `Logger` can change its level of logging by using `logger.level()` method.

    # output: 1
    logger.level()

    # Increase the logging level
    logger.level logging.WARN
    # output:  false
    logger.info "info message"

    # Decrease the logging level
    logger.level logging.LOG

    # output: [INFO] [0.031s] [kopi] info message
    logger.info "info message"

  @class
  ###
  class Logger

    ###
    Define logging method

    @private
    @param {Logger} logger
    @param {String} name
    @return {null}
    ###
    defineMethod = (logger, name) ->
      return if logger[name] and not logger[name].isNoop
      upper = name.toUpperCase()
      logger[name] = ->
        seconds = Math.round(new Date() - startTime) / 1000
        if console
          console[name]("[#{upper}] [#{seconds}s] [#{@_name}]", arguments...)
        return

    ###
    Define noop method for disallowed logging level

    @private
    @param {Logger} logger
    @param {String} name
    @return {null}
    ###
    defineNoopMethod = (logger, name) ->
      return if logger[name] and logger[name].isNoop
      logger[name] = NOOP_FN

    ###
    Constructor for logger

    @constructor
    @param {String} name
    @param {Object} options
    ###
    constructor: (name, options={}) ->
      throw new LoggerError("Logger must have a name") unless name
      @_level = if options.level? then options.level else settings.kopi.logging.level
      @_name = name
      # Initialize logging methods
      @level(@_level)
      # Cache the logger instance
      loggers[name] = this
      # Lazy loading real console object
      console or= window.console

    ###
    Return name of logger

    @return {String} attribute reader of name
    ###
    name: -> @_name

    ###
    Attribute accessor of logging level

    @param {Number} level   If `level` is not provided, returns
                            current logging level of logger.
                            If `level` is provided, update current
                            logger level of logger.
    @return {String|Logger}

    ###
    level: (level) ->
      return @_level if arguments.length == 0
      for name, value in ["log", "info", "warn", "error"]
        if value >= level
          defineMethod this, name
        else
          defineNoopMethod this, name
      @_level = level
      this

    ###
    Start a timer under the given name

    @param  {String}  name
    @param  {Object}  options

    @return {Logger}
    ###
    time: (name, options={}) ->
      key = "#{@_name}:#{name}"
      timer = timers[key]
      return if timer
      @log "#{name} started"
      timers[key] = new Date()
      accumulators[key] or= [] if options.accumulate
      this

    ###
    Stop a timer created by a call to `logger.time(name)`

    @param  {String}  name
    @param  {Object}  options

    @return {Logger}
    ###
    timeEnd: (name, options={}) ->
      key = "#{@_name}:#{name}"
      timer = timers[key]
      return if not timer
      time = new Date() - timer
      message = "#{name} stoped. spent #{time}ms."
      if options.accumulate
        accumulators[key].push(time)
        message += " total #{array.sum(accumulators[key])}ms. average #{array.average(accumulators[key])}ms."
      @log message
      timers[key] = null
      this

  # Default logger
  logger = new Logger("kopi")

  # Expose logging levels
  LOG: LOG
  INFO: INFO
  WARN: WARN
  ERROR: ERROR

  # Expose default logger methods
  log: -> logger.log(arguments...)
  info: -> logger.info(arguments...)
  warn: -> logger.warn(arguments...)
  error: -> logger.error(arguments...)
  time: -> logger.time(arguments...)
  timeEnd: -> logger.timeEnd(arguments...)

  ###
  Factory method for loggers

  Returns the default logger if `name` is not specified

  @param {String} name
  @param {Object} options

  @return {Logger}
  ###
  logger: (name, options) ->
    instance = if name then loggers[name] or new Logger(name) else logger
    instance.level options.level if options and options.level?
    instance
