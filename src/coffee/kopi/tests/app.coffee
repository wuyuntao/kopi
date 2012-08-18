define "kopi/tests/app", (require, exports, module) ->

  $ = require "jquery"
  q = require "qunit"
  base = require "kopi/tests/base"
  views = require "kopi/views"
  app = require "kopi/app"
  router = require "kopi/app/router"
  uri = require "kopi/utils/uri"

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

  $ ->
    app = new DeltaApp()
    app.start()

    q.module("kopi/app")

    q.test "push state", ->
      app.configure
        usePushState: true
        useHashChange: false
        useInterval: false
        alwaysUseHash: false

      q.stop()
      app.once DeltaApp.REQUEST_EVENT, (e, url) ->
        q.equal url.path, "/alpha"
        q.start()
      app.load "/alpha"
      app.currentURL = "/alpha"
      q.equal loc.pathname, "/alpha"

      q.stop()
      app.once DeltaApp.REQUEST_EVENT, (e, url) ->
        q.equal url.path, "/alpha/1"
        q.start()
      app.load "/alpha/1"
      app.currentURL = "/alpha/1"
      q.equal loc.pathname, "/alpha/1"

      q.stop()
      app.once DeltaApp.REQUEST_EVENT, (e, url) ->
        q.equal url.path, "/alpha"
        q.start()
      hist.back()
      q.stop()
      waitFn = ->
        app.currentURL = "/alpha"
        q.equal loc.pathname, "/alpha"
        q.start()

        # Revert original URL
        hist.pushState(null, null, base)

      # Wait for history being changed
      setTimeout waitFn, 500

    q.test "push state with hash", ->
      app.configure
        usePushState: true
        useHashChange: false
        useInterval: false
        alwaysUseHash: true

      q.stop()
      app.once DeltaApp.REQUEST_EVENT, (e, url) ->
        q.equal url.path, "/alpha"
        q.start()
      app.load "/alpha"
      app.currentURL = "/alpha"
      q.equal loc.hash, "#../alpha"

      q.stop()
      app.once DeltaApp.REQUEST_EVENT, (e, url) ->
        q.equal url.path, "/alpha/1"
        q.start()
      app.load "/alpha/1"
      app.currentURL = "/alpha/1"
      q.equal loc.hash, "#../alpha/1"

      q.stop()
      app.once DeltaApp.REQUEST_EVENT, (e, url) ->
        q.equal url.path, "/alpha"
        q.start()
      hist.back()
      q.stop()
      waitFn = ->
        app.currentURL = "/alpha"
        q.equal loc.hash, "#../alpha"
        q.start()

        # Revert original URL
        hist.pushState(null, null, base)

      # Wait for history being changed
      setTimeout waitFn, 500

    q.test "hash change", ->
      app.configure
        usePushState: false
        useHashChange: true
        useInterval: false
        alwaysUseHash: true

      app.load "/alpha"
      app.currentURL = "/alpha"
      q.equal loc.hash, "#../alpha"

      app.load "/alpha/1"
      app.currentURL = "/alpha/1"
      q.equal loc.hash, "#../alpha/1"

      hist.back()
      q.stop()
      waitFn = ->
        app.currentURL = "/alpha"
        q.equal loc.hash, "#../alpha"
        q.start()

        # Revert original URL
        hist.pushState(null, null, base)

      # Wait for history being changed
      setTimeout waitFn, 500
