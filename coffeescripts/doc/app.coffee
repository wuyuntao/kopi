define "doc/app", (require, exports, module) ->

  App = require("kopi/app").App
  Navbar = require("kopi/ui/navigation").Navbar
  ViewSwitcher = require("kopi/ui/viewswitchers").ViewSwitcher
  notification = require("kopi/ui/notification")

  require "doc/settings"
  require "doc/routes"

  class DocApp extends App

    onstart: ->
      super
      this.navbar = new Navbar(position: Navbar.POS_TOP_FIXED)
        .skeletonTo(this.viewport.element)
        .render()
      this.viewSwitcher = new ViewSwitcher(position: ViewSwitcher.POS_TOP_FIXED)
        .skeletonTo(this.viewport.element)
        .render()
      notification.loaded()

    onstop: ->
      super
      this.navbar.destroy()
      this.viewSwitcher.destroy()

  DocApp: DocApp
