define "kopi/demos/main", (require, exports, module) ->

  app = require "kopi/app"
  navigation = require "kopi/ui/navigation"
  viewswitchers = require "kopi/ui/viewswitchers"

  require "kopi/demos/routes"

  class DemoApp extends app.App

    onstart: ->
      super
      this.navBar = new navigation.Navbar()
        .skeletonTo(this.viewport.element)
        .render()
      this.viewSwitcher = new viewswitchers.ViewSwitcher()
        .skeletonTo(this.viewport.element)
        .render()

    onstop: ->
      super
      this.navbar.destroy()
      this.viewSwitcher.destroy()

  new DemoApp().start()
