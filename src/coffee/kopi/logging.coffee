define "kopi/logging", (require, exports, module) ->

  array = require "kopi/utils/array"
  object = require "kopi/utils/object"
  settings = require "kopi/settings"
  exceptions = require "kopi/exceptions"

  class LoggerError extends exceptions.ValueError

  LOG = 0
  INFO = 1
  WARN = 2
  ERROR = 3

  NOOP_FN = ->
  NOOP_FN.isNoop = true

  # Store all loggers with their names
  loggers = {}

  ###
  Improve original console with tag, time and extra handlers

  # TODO Implement logging handler mechanism like Python
  ###
  class Logger

    # @type {Date}    Start time of logger
    start = (window.__KOPI__START_TIME or= new Date())

    # @type {Hash}    Log timers
    timers = {}
    # @type {Hash}    Log accumulators
    accumulators = {}
    # @type {Console} Local reference of console object
    console = null

    ###
    Define logging method

    @private
    ###
    defineMethod = (logger, name) ->
      return if logger[name] and not logger[name].isNoop
      logger[name] = ->
        seconds = Math.round(new Date() - start) / 1000
        if console
          console[name] "[#{seconds}s] [#{@_name}]", arguments...
        return

    ###
    Define noop method for disallowed logging level

    @private
    ###
    defineNoopMethod = (logger, name) ->
      return if logger[name] and logger[name].isNoop
      logger[name] = NOOP_FN

    ###
    Constructor for logger

    @constructor
    @param {String} name
    ###
    constructor: (name, options={}) ->
      throw new LoggerError("Logger must have a name") unless name
      @_level = settings.kopi.logging.level
      @_name = name
      # Initialize logging methods
      @level @_level
      # Cache the logger instance
      loggers[name] = this
      # Lazy loading real console object
      console or= window.console

    ###
    Return name of logger
    ###
    name: -> @_name

    ###
    Accessor of logging level
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
    @param  {Hash}    options

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
    Stop a timer created by a call to Logger.time(name)

    @param  {String}  name
    @param  {Hash}    options

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
  ###
  logger: (name) -> if name then loggers[name] or new Logger(name) else logger
