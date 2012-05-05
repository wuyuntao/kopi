define "kopi/demos/views", (require, exports, module) ->

  views = require "kopi/views"
  lists = require "kopi/ui/lists"
  adapters = require "kopi/ui/groups/adapters"
  navigation = require "kopi/ui/navigation"
  viewswitchers = require "kopi/ui/viewswitchers"
  settings = require "kopi/demos/settings"
  Text = require("kopi/ui/text").Text

  class IndexView extends views.View

    constructor: ->
      super
      this.nav = new navigation.Nav(title: "Index")
      this.view = new viewswitchers.View()
      this.list = new lists.NavList()

    oncreate: ->
      self = this
      self.app.navBar.add(self.nav)
      self.nav.skeleton()

      self.app.viewSwitcher.add(self.view)
      self.view.skeleton()

      self.list
        .adapter(new adapters.ArrayAdapter([
          ["App", "/app/"]
          ["Model", "/model/"]
          ["View", "/view/"]
          ["UI", "/ui/"]
        ])).skeletonTo(self.view.element)
      super

    onstart: ->
      self = this
      self.app.navBar.show(self.nav)
      self.app.viewSwitcher.show(self.view)
      self.nav.render()
      self.view.render()
      self.list.render()
      super

    ondestroy: ->
      self.nav.destroy()
      self.view.destroy()
      self.list.destroy()
      super

  IndexView: IndexView
