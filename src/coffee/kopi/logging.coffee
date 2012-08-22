define "kopi/logging", (require, exports, module) ->

  array = require "kopi/utils/array"
  object = require "kopi/utils/object"
  settings = require "kopi/settings"
  ValueError = require("kopi/exceptions").ValueError

  # Enumeration values of logger levels
  LOG = 0
  INFO = 1
  WARN = 2
  ERROR = 3

  NOOP_FN = -> false
  NOOP_FN.isNoop = true

  # Store all loggers with their names
  loggers = {}
  # Start time of logger
  startTime = (window.__KOPI__START_TIME or= new Date())
  # Timers for loggers
  timers = {}
  # Accumulators for loggers
  accumulators = {}
  # Local reference of console object
  console = null

  ###
  # Logger

  A simple logging library that improve the original console
  with timeline and custom tag support.

  Just like `console`, a logger has four logging levels in a
  specific order.

  ```
  LOG < INFO < WARN < ERROR
  ```

  ###
  class Logger

    # Define logging method by given name
    defineMethod = (logger, name) ->
      return if logger[name] and not logger[name].isNoop
      upper = name.toUpperCase()
      logger[name] = ->
        seconds = Math.round(new Date() - startTime) / 1000
        if console
          console[name]("[#{upper}] [#{seconds}s] [#{@_name}]", arguments...)
        return

    # Define noop method for disallowed logging level
    defineNoopMethod = (logger, name) ->
      return if logger[name] and logger[name].isNoop
      logger[name] = NOOP_FN

    ###
    ## Instantiate a logger instance

    This module provides a factory method `logging.logger()`
    to create loggers.

    Multiple calls to `logging.logger()` with the same name will
    always return a reference to the same `Logger` instance.

    ```coffeescript
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
    ```

    ###
    constructor: (name, options={}) ->
      throw new ValueError("Logger must have a name") unless name
      @_level = if options.level? then options.level else settings.kopi.logging.level
      @_name = name
      # Initialize logging methods
      @level(@_level)
      # Cache the logger instance
      loggers[name] = this
      # Lazy loading real console object
      console or= window.console

    ###
    ## logger.log()

    `Logger` has a similar interface to `console` object. But only
    following methods are supported: `log`, `info`, `warn`, `error`,
    `time`, `timeEnd`.

    ```coffeescript
    # output: [LOG] [0.027s] [kopi] log message [1, 2, 3]
    logger.log "log message", [1, 2, 3]
    ```

    ###
    log: NOOP_FN
    ###
    ## logger.info()

    Same as `logger.log()`.
    ###
    info: NOOP_FN
    ###
    ## logger.warn()

    Same as `logger.log()`.
    ###
    warn: NOOP_FN
    ###
    ## logger.error()

    Same as `logger.log()`.
    ###
    error: NOOP_FN

    ###
    ## logger.time(label)

    Start a timer

    ```coffeescript
    # output: [LOG] [0.034s] [kopi] time started
    logger.time "prof"
    ```

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
    ## logger.timeEnd(label)

    Finish timer and record the time spent.

    ```coffeescript
    # output [LOG] [1.035s] [kopi] time stoped. spent 1001ms.
    logger.timeEnd "prof"
    ```

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

    ###
    ## logger.name()

    Return name of logger

    ###
    name: -> @_name

    ###
    ## logger.level([level])

    Attribute accessor of logging level.

    If `level` is not provided, returns current logging level of logger.
    If `level` is provided, update current logging level of logger.

    ```coffeescript
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
    ```

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

  # Factory method for loggers
  logger: (name, options) ->
    instance = if name then loggers[name] or new Logger(name) else logger
    instance.level options.level if options and options.level?
    instance
