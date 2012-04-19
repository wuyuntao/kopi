define "kopi/demos/views/ui", (require, exports, module) ->

  View = require("kopi/views").View
  navigation = require("kopi/ui/navigation")
  viewswitchers = require "kopi/ui/viewswitchers"
  NavList = require("kopi/ui/lists").NavList
  ArrayAdapter = require("kopi/ui/lists/adapters").ArrayAdapter
  reverse = require("kopi/app/router").reverse

  class UIView extends View

    constructor: ->
      super
      backButton = new navigation.NavButton
        url: reverse("index")
        titleText: "Back"
      this.nav = new navigation.Nav
        title: "UI"
        leftButton: backButton
      this.view = new viewswitchers.View()
      this.list = new NavList()

    oncreate: ->
      this.app.navBar.add(this.nav)
      this.nav.skeleton()
      this.app.viewSwitcher.add(this.view)
      this.view.skeleton()
      this.list
        .adapter(new ArrayAdapter([
          ["Buttons", "/ui/buttons/"]
          ["Controls", "/ui/controls/"]
          ["Dialogs", "/ui/dialogs/"]
          ["Lists", "/ui/lists/"]
          ["Tabs", "/ui/tabs/"]
        ])).skeletonTo(this.view.element)
      super

    onstart: ->
      this.app.navBar.show(this.nav)
      this.app.viewSwitcher.show(this.view)
      this.nav.render()
      this.view.render()
      this.list.render()
      super

    ondestroy: ->
      this.nav.destroy()
      this.view.destroy()
      this.list.destroy()
      super

  UIView: UIView
