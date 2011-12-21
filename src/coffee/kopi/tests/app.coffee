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

    module("kopi.app")

    test "push state", ->
      app = new DeltaApp
        usePushState: true
        useHashChange: false
        useInterval: false
        alwaysUseHash: false
      app.start()

      app.load "/alpha"
      app.currentURL = "/alpha"
      equals loc.pathname, "/alpha"

      app.load "/alpha/1"
      app.currentURL = "/alpha/1"
      equals loc.pathname, "/alpha/1"

      hist.back()
      app.currentURL = "/alpha"
      equals loc.pathname, "/alpha"

    # test "push state with hash", ->
    #   app = new DeltaApp
    #     usePushState: true
    #     useHashChange: false
    #     useInterval: false
    #     alwaysUseHash: true
    #   app.start()

    #   app.stop()

    # test "hash change", ->
    #   app = new DeltaApp
    #     usePushState: false
    #     useHashChange: true
    #     useInterval: false
    #     alwaysUseHash: true
    #   app.start()

    #   app.stop()

    # test "interval", ->
    #   app = new DeltaApp
    #     usePushState: false
    #     useHashChange: false
    #     useInterval: false
    #     alwaysUseHash: true
    #   app.start()

    #   app.stop()

    # Test flow
    # flow = (app) ->
    #   app.start()

    #   # Should start AlphaView
    #   app.load "/alpha"
    #   equals loc.pathname, "/alpha"
    #   view1 = app.currentView
    #   equals view1.guid, ""
    #   url1 = uri.parse app.currentURL
    #   equals url1.path, "/alpha"

    #   # Should start another AlphaView
    #   app.load "/alpha/1?query=ignore"
    #   equals loc.pathname, "/alpha/1?query=ignore"
    #   view2 = app.currentView
    #   equals view2.guid, ""
    #   ok view2.guid != view1.guid
    #   url2 = uri.parse app.currentURL
    #   equals url.path, "/alpha/1"

    #   app.stop()

