kopi.module('kopi.logging')
  .require('kopi.utils')
  .define (exports, utils) ->

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
      # @type {Hash}    默认设置
      defaults =
        level:    0     # 默认的日志等级
        console:  true  # 是否启用控制台日志
        # html:     false # 是否在页面上显示日志（暂不支持）
        # database: false # 是否数据库记录日志（暂不支持）
        # remote:   false # 是否向远程服务器发送日志（暂不支持）
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
        throw new Error("Invalid logger level") if not (level of levels)
        options = $.extend {}, defaults, options or {}
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
      设置日志参数

      @param  {Hash}    options     参数
      ###
      setup: (options={}) ->
        defaults = $.extend defaults, options
        return

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

      debug:  (message, options) -> send("debug", message, options)
      info:   (message, options) -> send("info", message, options)
      warn:   (message, options) -> send("warn", message, options)
      error:  (message, options) -> send("error", message, options)

    exports.logger = new Logger()
