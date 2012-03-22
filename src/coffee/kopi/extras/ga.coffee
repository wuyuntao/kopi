define "kopi/extras/ga", (require, exports, module) ->

  $ = require "jquery"
  settings = require "kopi/settings"
  logger = logging.logger(module.id)
  win = window

  ###
  An Adapter for Google Analytics SDK

  Usage:
    tracker.setup
      account:  "UA-xxxxx-x"
      domain: "kopi.com"
    tracker.load()
    tracker.pageview("/xs/46/")
    tracker.event("book", "download", "1")
  ###
  class Tracker

    kls = this
    kls.VISITOR_LEVEL = 1
    kls.SESSION_LEVEL = 2
    kls.PAGE_LEVEL = 3

    ###
    @constructor
    ###
    constructor: ->
      win._gaq ||= []
      this.account = null
      this.domain = null

    ###
    Is GA script loaded successfully?
    ###
    isInitialized: -> typeof win._gat isnt "undefined"

    ###
    Add Google Analytics tracking script to page
    ###
    initialize: ->
      return if this.isInitialized()
      if not settings.tracking.account
        logger.error "Account ID for Google Analytics must be specified."
        return

      win._gaq.push ["_setAccount", settings.tracking.account]
      win._gaq.push ["_setDomainName", settings.tracking.domain]
      win._gaq.push ["_trackPageview"]

      ga = document.createElement("script")
      ga.type = "text/javascript"
      ga.async = true
      ga.src = (if location.protocol is "https:" then "https://ssl." else "http://www.") +
        "google-analytics.com/" + (if settings.debug then "u/ga_debug.js" else "ga.js")
      s = document.getElementsByTagName('script')[0]
      s.parentNode.insertBefore(ga, s)
      return

    ###
    Update a custom vars
    ###
    setVar: (slot, key, value, level=kls.PAGE_LEVEL) ->
      win._gaq.push ['_setCustomVar', slot, key, value, level]
      this

    ###
    Update custom vars
    ###
    setVars: (vars={}, level=kls.PAGE_LEVEL) ->
      slot = 1
      for key, value of vars
        this.attrs(slot, key, value, level)
        slot++
      this

    ###
    Track page view
    ###
    pageview: (url) ->
      logger.info "Track page: #{url}"
      win._gaq.push ["_trackPageview", url]
      return

    ###
    Track event
    ###
    event: (category, action, label="", value=0) ->
      logger.info "Track event: #{category}:#{action}:#{label} (#{value})"
      win._gaq.push ["_trackEvent", category, action, label, value]
      return

  tracker: new Tracker()
