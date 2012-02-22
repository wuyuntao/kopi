define "kopi/logging", (require, exports, module) ->

  array = require "kopi/utils/array"
  object = require "kopi/utils/object"
  settings = require "kopi/settings"
  exceptions = require "kopi/exceptions"

  class LoggerError extends exceptions.ValueError

  # Store all loggers with their names
  loggers = {}

  ###
  日志
  ###
  class Logger
    # @type {Date}    起始时间
    start = new Date()
    # @type {Hash}    计时器
    timers = {}
    # @type {Hash}    累加器
    accumulators = {}
    # @type {Hash}    日志级别
    levels =
      log:    0
      debug:  1
      info:   2
      warn:   3
      error:  4
    # @type {Console} 日志对象
    console = window.console

    ###
    记录日志

    @param  {String}  name      name of logger
    @param  {String}  level     日志级别
    @param  {String}  message   日志内容
    @param  {Hash}    options   为单条日志做的特殊设置
    ###
    send = (name, level, message, options={}) ->
      throw new LoggerError("Invalid logger level: #{level}") unless (level of levels)
      options = object.extend {}, settings.kopi.logging, options
      return false if levels[level] < options.level

      seconds = Math.round(new Date() - start) / 1000

      if options.console and console
        # MSIE 不支持 console.debug() 方法，所以替换成 console.log()
        action = if level of console then level else "log"
        if options.raw
          console[action]("[#{seconds}s] [#{name}]")
          console[action](message)
        else
          console[action]("[#{seconds}s] [#{name}] #{message}")

    constructor: (name) ->
      throw new LoggerError("Logger must have a name") unless name
      this._name = name
      this._disabled = false
      loggers[name] = this

    name: -> this._name

    enable: ->
      this._disabled = false
      this

    disable: ->
      this._disabled = true
      this

    ###
    计算花费的时间

    @param  {String}  name        行动名
    @param  {Hash}    options     额外的参数

    ###
    time: (name, options={}) ->
      return this if this._disabled
      key = "#{this._name}:#{name}"
      timer = timers[key]
      if timer
        # stop timer
        time = new Date() - timer
        message = "#{name} stoped. spent #{time}ms."
        if options.accumulate
          accumulators[key].push(time)
          message += " total #{array.sum(accumulators[key])}ms. average #{array.average(accumulators[key])}ms."
        send(this._name, "debug", message)
        timers[key] = null

      else
        # start timer
        send(this._name, "debug", "#{name} started.")
        timers[key] = new Date()
        accumulators[key] or= [] if options.accumulate
      this

    # 定义 debug, info, warn & error 方法
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
