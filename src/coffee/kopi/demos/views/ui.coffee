define "kopi/demos/views/ui", (require, exports, module) ->

  View = require("kopi/views").View
  navigation = require("kopi/ui/navigation")
  viewswitchers = require "kopi/ui/viewswitchers"
  NavList = require("kopi/ui/lists").NavList
  ArrayAdapter = require("kopi/ui/lists/adapters").ArrayAdapter

  class UIView extends View

    constructor: ->
      super
      backButton = new navigation.NavButton(url: "/").text("Back")
      this.nav = new navigation.Nav
        title: "UI"
        leftButton: backButton
      this.view = new viewswitchers.View()
      this.list = new NavList()

    oncreate: ->
      self = this
      self.app.navBar.add(self.nav)
      self.nav.skeleton()

      self.app.viewSwitcher.add(self.view)
      self.view.skeleton()

      self.list
        .adapter(new ArrayAdapter([
          ["Buttons", "/ui/buttons/"]
          ["Controls", "/ui/controls/"]
          ["Dialogs", "/ui/dialogs/"]
          ["Lists", "/ui/lists/"]
          ["Tabs", "/ui/tabs/"]
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

  class UIButtonView extends View

    constructor: ->
      super
      this.nav = new Nav(title: "Buttons")
      this.view = new viewswitchers.View()

    oncreate: ->
      self = this
      self.app.navBar.add(self.nav)
      self.nav.skeleton()

      self.app.viewSwitcher.add(self.view)
      self.view.skeleton()

      super

    onstart: ->
      self = this
      self.app.navBar.show(self.nav)
      self.app.viewSwitcher.show(self.view)
      self.nav.render()
      self.view.render()
      super

    ondestroy: ->
      self.nav.destroy()
      self.view.destroy()
      super

  UIView: UIView
  UIButtonView: UIButtonView
