define "kopi/settings", (require, exports, module) ->

  $ = require "jquery"
  exceptions = require "kopi/exceptions"

  kopi =
    debug: true

    app:
      # @type {Boolean}         Enable task queue for application
      task: false
      # @type  {String}         Start URL of app
      startURL: null
      # @type  {Boolean}        Use pushState for URL change if available
      usePushState: true
      # @type  {Boolean}        Use hashChange for URL change if available
      useHashChange: true
      # @type  {Boolean}        Use interval for URL change if available
      useInterval: true
      # @type {Number}          time to check state change
      interval: 50
      # @type  {Boolean}        Use hash even pushState is available. Good for offline-capable app
      alwaysUseHash: true
      # @type  {Boolean}        Do page redirect if no matched route is found
      redirectWhenNoRouteFound: false

    i18n:
      # @type {LocaleString}    Translation is currently used
      locale: "en"
      # @type {LocaleString}    A fallback when current transition is missing
      fallback: "en"

    logging:
      # @type  {Integer}        Default log level
      level:    0
      # @type  {Boolean}        Write logs to console
      console:  true
      # @type  {Boolean}        Write logs to HTML element (not supported yet)
      # html:     false
      # @type  {Boolean}        Write logs to database (not supported yet)
      # database: false
      # @type  {Boolean}        Send logs to server (not supported yet)
      # remote:   false

    ui:
      # @type  {String}         CSS class prefix added to widgets
      prefix: "kopi"
      notification:
        prefix: "kopi-notification"

    db:
      indexedDB:
        # @type  {String}       Default database name for indexed db
        name: "kopi_db"

    tracking:
      # @type  {String}         Google Analytics Account ID
      account: null
      # @type  {String}         Domain to track
      domain: location.host

  # Read settings from localStorage
  load = ->
    throw new exceptions.NotImplementedError()

  # Save settings to localStorage
  commit = ->
    throw new exceptions.NotImplementedError()

  kopi: kopi
  load: load
  commit: commit
  extend: ->
    # Deeply extend
    $.extend true, exports, arguments...
