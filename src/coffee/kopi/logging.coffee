define "kopi/logging", (require, exports, module) ->

  array = require "kopi/utils/array"
  object = require "kopi/utils/object"
  settings = require "kopi/settings"
  exceptions = require "kopi/exceptions"

  class LoggerError extends exceptions.ValueError

  # Store all loggers with their names
  loggers = {}

  ###
  Improve original console with tag, time and extra handlers

  # TODO Implement logging handler mechanism like Python
  ###
  class Logger

    # @type {Date}    Start time of logger
    start = new Date()

    # @type {Hash}    Log timers
    timers = {}
    # @type {Hash}    Log accumulators
    accumulators = {}
    # @type {Hash}    Log level
    levels =
      log:    0
      debug:  1
      info:   2
      warn:   3
      error:  4
    # @type {Console} 日志对象
    console = window.console

    ###
    send log to logging handler

    @param  {String}  name
    @param  {String}  level
    @param  {String}  message
    @param  {Hash}    options
    ###
    send = (name, level, message, options={}) ->
      throw new LoggerError("Invalid logger level: #{level}") unless (level of levels)
      options = object.extend {}, settings.kopi.logging, options
      return false if levels[level] < options.level

      seconds = Math.round(new Date() - start) / 1000

      if options.console and console
        # Provide an alternate method since level might not be supported in some browser
        action = if level of console then level else "log"
        if options.raw
          console[action]("[#{seconds}s] [#{name}]")
          console[action](message)
        else
          console[action]("[#{seconds}s] [#{name}] #{message}")

    ###
    Constructor for logger

    @constructor
    @param {String} name
    ###
    constructor: (name) ->
      throw new LoggerError("Logger must have a name") unless name
      this._name = name
      this._disabled = false
      loggers[name] = this

    ###
    Return name of logger
    ###
    name: -> this._name

    ###
    Enable logger
    ###
    enable: ->
      this._disabled = false
      this

    ###
    Disable logger
    ###
    disable: ->
      this._disabled = true
      this

    ###
    Start a timer under the given name

    @param  {String}  name
    @param  {Hash}    options

    ###
    time: (name, options={}) ->
      return this if this._disabled
      key = "#{this._name}:#{name}"
      timer = timers[key]
      return if timer
      send(this._name, "debug", "#{name} started.")
      timers[key] = new Date()
      accumulators[key] or= [] if options.accumulate
      this

    ###
    Stop a timer created by a call to Logger.time(name)

    @param  {String}  name
    @param  {Hash}    options

    ###
    timeEnd: (name, options={}) ->
      key = "#{this._name}:#{name}"
      timer = timers[key]
      return if not timer
      time = new Date() - timer
      message = "#{name} stoped. spent #{time}ms."
      if options.accumulate
        accumulators[key].push(time)
        message += " total #{array.sum(accumulators[key])}ms. average #{array.average(accumulators[key])}ms."
      send(this._name, "debug", message)
      timers[key] = null
      this

    # Define debug, info, warn & error methods
    proto = this.prototype
    defineMethod = (level) ->
      proto[level] = (message, options) ->
        return this if this._disabled
        send(this._name, level, message, options)
        this
    defineMethod(level) for level of levels

  # Default logger
  logger = new Logger("kopi")

  time: -> logger.time(arguments...)
  debug: -> logger.debug(arguments...)
  info: -> logger.info(arguments...)
  warn: -> logger.warn(arguments...)
  error: -> logger.error(arguments...)
  logger: (name) ->
    # Factory method for loggers
    if name then loggers[name] or new Logger(name) else logger
