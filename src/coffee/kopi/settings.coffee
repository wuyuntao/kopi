define "kopi/settings", (require, exports, module) ->

  $ = require "jquery"
  {NotImplementedError} = require "kopi/exceptions"

  kopi =
    debug: true

    app:
      # Enable task queue for application
      task: false
      # Start URL of app
      startURL: null
      # Use pushState for URL change if available
      usePushState: true
      # Use hashChange for URL change if available
      useHashChange: true
      # Use interval for URL change if available
      useInterval: true
      # Time to check state change
      interval: 50
      # Use hash even pushState is available. Good for offline-capable app
      alwaysUseHash: true
      # Do page redirect if no matched route is found
      redirectWhenNoRouteFound: false

    i18n:
      # Translation is currently used
      locale: "en"
      # A fallback when current transition is missing
      fallback: "en"

    logging:
      # Default log level
      level:    0

    ui:
      # CSS class prefix added to widgets
      prefix: "kopi"
      notification:
        prefix: "kopi-notification"
      imageDir: "/images"

    db:
      indexedDB:
        # Default database name for indexed db
        name: "kopi_db"

    tracking:
      # Google Analytics Account ID
      account: null
      # Domain to track
      domain: location.host

  # Read settings from localStorage
  load = -> throw new NotImplementedError()

  # Save settings to localStorage
  commit = -> throw new NotImplementedError()

  kopi: kopi
  load: load
  commit: commit
  extend: ->
    # Deeply extend
    $.extend true, exports, arguments...
