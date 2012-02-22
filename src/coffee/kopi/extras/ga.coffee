define "kopi/extras/ga", (require, exports, module) ->

  $ = require "jquery"

  # An Adapter for Google Analytics
  #
  # Usage:
  # tracker.setup
  #     account:  "UA-xxxxx-x"
  #     domain: "zuikong.com"
  # tracker.load()
  # tracker.pageview("/xs/46/")
  # tracker.event("book", "download_apk", )
  class Tracker

    # GA Tracker 对象
    constructor: ->
      this.account = null
      this.domain = null
      this.tracker = null

    # 脚本是否加载完成
    isLoaded: -> typeof win._gat isnt "undefined"

    # 加载 Google Analytics 脚本
    load: ->
      return if this.isLoaded()

      self = this
      successFn = ->
        if not self.isLoaded()
          # TODO Retry?
          win._gaq.push ["_trackPageview"]
          logger.error "Failed to load Google Analytics script. Error: Missing _gat"
      errorFn = (error) ->
          # TODO Retry?
          logger.error "Failed to load Google Analytics script. Error: #{error}"
      $.ajax
        url: this._script()
        type: "GET"
        dataType: "script"
        cache: true
        success: successFn
        error: errorFn
      return

    _script: ->
      host = if location.protocol is "https:" then "https://ssl." else "http://www."
      script = host + "google-analytics.com/" + (if this.debug then "u/ga_debug.js" else "ga.js")

    # 设置 Tracker
    #
    # 参数：
    # account: "UA-xxxxx-x"
    # domain: "zuikong.com"
    setup: (options) ->
      if "debug" of options
        this.debug = !!debug

      if options.account
        this.account = options.account
        win._gaq.push ["_setAccount", options.account] if win._gaq

      if options.domain
        this.domain = options.domain
        win._gaq.push ["_setDomainName", options.domain] if win._gaq
      return

    pageview: (url) ->
      logger.log "Track page: #{url}"
      win._gaq.push ["_trackPageview", url] if win._gaq
      return

    event: (category, action, label="", value=0) ->
      logger.log "Track event: #{category}:#{action}:#{label} (#{value})"
      win._gaq.push ["_trackEvent", category, action, label, value] if win._gaq
      return

  tracker: new Tracker()
