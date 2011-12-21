kopi.module("kopi.tests.app")
  .require("kopi.tests.base")
  .require("kopi.views")
  .require("kopi.app")
  .require("kopi.app.router")
  .require("kopi.utils.uri")
  .define (exports, base, views, app, router, uri) ->

    loc = location
    hist = history
    win = $(window)
    base = uri.current()

    # View definitions
    class AlphaView extends views.View

    class BetaView extends views.View

    class GammaView extends views.View

    # App definition
    class DeltaApp extends app.App

    # Route definitions
    router
      .view(AlphaView)
        .route('/alpha', name: 'alpha-list')
        .route('/alpha/:id', name: 'alpha-detail')
        .end()
      .view(BetaView)
        .route('/beta', name: 'beta-list', group: true)
        .route('/beta/:id', name: 'beta-detail', group: true)
        .end()
      .view(GammaView)
        .route('/gamma/:id/page', name: 'gamma-page-list', group: "id")
        .route('/gamma/:id/page/:page', name: 'gamma-page-detail', group: ["id"])
        .end()

    app = new DeltaApp()
    app.start()

    module("kopi.app")

    test "push state", ->
      app.configure
        usePushState: true
        useHashChange: false
        useInterval: false
        alwaysUseHash: false

      stop()
      app.once DeltaApp.REQUEST_EVENT, (e, url) ->
        equals url.path, "/alpha"
        start()
      app.load "/alpha"
      app.currentURL = "/alpha"
      equals loc.pathname, "/alpha"

      stop()
      app.once DeltaApp.REQUEST_EVENT, (e, url) ->
        equals url.path, "/alpha/1"
        start()
      app.load "/alpha/1"
      app.currentURL = "/alpha/1"
      equals loc.pathname, "/alpha/1"

      stop()
      app.once DeltaApp.REQUEST_EVENT, (e, url) ->
        equals url.path, "/alpha"
        start()
      hist.back()
      stop()
      waitFn = ->
        app.currentURL = "/alpha"
        equals loc.pathname, "/alpha"
        start()

        # Revert original URL
        hist.pushState(null, null, base)

      # Wait for history being changed
      setTimeout waitFn, 500

    test "push state with hash", ->
      app.configure
        usePushState: true
        useHashChange: false
        useInterval: false
        alwaysUseHash: true

      stop()
      app.once DeltaApp.REQUEST_EVENT, (e, url) ->
        equals url.path, "/alpha"
        start()
      app.load "/alpha"
      app.currentURL = "/alpha"
      equals loc.hash, "#../alpha"

      stop()
      app.once DeltaApp.REQUEST_EVENT, (e, url) ->
        equals url.path, "/alpha/1"
        start()
      app.load "/alpha/1"
      app.currentURL = "/alpha/1"
      equals loc.hash, "#../alpha/1"

      stop()
      app.once DeltaApp.REQUEST_EVENT, (e, url) ->
        equals url.path, "/alpha"
        start()
      hist.back()
      stop()
      waitFn = ->
        app.currentURL = "/alpha"
        equals loc.hash, "#../alpha"
        start()

        # Revert original URL
        hist.pushState(null, null, base)

      # Wait for history being changed
      setTimeout waitFn, 500

    test "hash change", ->
      app.configure
        usePushState: false
        useHashChange: true
        useInterval: false
        alwaysUseHash: true

      app.load "/alpha"
      app.currentURL = "/alpha"
      equals loc.hash, "#../alpha"

      app.load "/alpha/1"
      app.currentURL = "/alpha/1"
      equals loc.hash, "#../alpha/1"

      hist.back()
      stop()
      waitFn = ->
        app.currentURL = "/alpha"
        equals loc.hash, "#../alpha"
        start()

        # Revert original URL
        hist.pushState(null, null, base)

      # Wait for history being changed
      setTimeout waitFn, 500
