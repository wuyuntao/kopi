kopi.module('kopi.logging')
  .require('kopi.utils')
  .require('kopi.settings')
  .define (exports, utils, settings) ->

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
        debug:  0
        info:   1
        warn:   2
        error:  3
      # @type {Console} 日志对象
      console = window.console

      ###
      记录日志

      @param  {String}  level     日志级别
      @param  {String}  message   日志内容
      @param  {Hash}    options   为单条日志做的特殊设置
      ###
      send = (level, message, options={}) ->
        throw new Error("Invalid logger level") unless (level of levels)
        options = utils.extend {}, settings.kopi.logging, options
        return false if levels[level] < options.level

        seconds = Math.round(new Date() - start) / 1000

        if options.console and console
          # MSIE 不支持 console.debug() 方法，所以替换成 console.log()
          action = if level of console then level else "log"
          if options.raw
            console[action]("[#{seconds}s]")
            console[action](message)
          else
            console[action]("[#{seconds}s] #{message}")

      ###
      计算花费的时间

      @param  {String}  name        行动名
      @param  {Hash}    options     额外的参数

      ###
      time: (name, options={}) ->
        timer = timers[name]
        if timer
          # stop timer
          time = new Date() - timer
          message = "#{name} stoped. spent #{time}ms."
          if options.accumulate
            accumulators[name].push(time)
            message += " total #{utils.sum(accumulators[name])}ms. average #{utils.average(accumulators[name])}ms."
          send("debug", message)
          timers[name] = null

        else
          # start timer
          send("debug", "#{name} started.")
          timers[name] = new Date()
          accumulators[name] or= [] if options.accumulate
        return

      # 定义 debug, info, warn & error 方法
      for level of levels
        ((l) =>
          this.prototype[l] = (message, options) -> send(l, message, options)
        )(level)

    exports.logger = logger = new Logger()
    exports.time = logger.time
    exports.debug = logger.time
    exports.info = logger.info
    exports.warn = logger.warn
    exports.error = logger.error
