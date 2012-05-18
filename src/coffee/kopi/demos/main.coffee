define "kopi/demos/main", (require, exports, module) ->

  app = require "kopi/app"
  Navbar = require("kopi/ui/navigation").Navbar
  ViewSwitcher = require("kopi/ui/viewswitchers").ViewSwitcher

  require "kopi/demos/routes"
  require "kopi/demos/settings"

  class DemoApp extends app.App

    onstart: ->
      super
      this.navbar = new Navbar(position: Navbar.POS_TOP_FIXED)
        .skeletonTo(this.viewport.element)
        .render()
      this.viewSwitcher = new ViewSwitcher()
        .skeletonTo(this.viewport.element)
        .render()

    onstop: ->
      super
      this.navbar.destroy()
      this.viewSwitcher.destroy()

  new DemoApp().start()
