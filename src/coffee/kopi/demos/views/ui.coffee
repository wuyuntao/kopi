define "kopi/demos/views/ui", (require, exports, module) ->

  reverse = require("kopi/app/router").reverse
  View = require("kopi/views").View
  navigation = require("kopi/ui/navigation")
  viewswitchers = require "kopi/ui/viewswitchers"
  NavList = require("kopi/ui/lists").NavList
  ArrayAdapter = require("kopi/ui/groups/adapters").ArrayAdapter

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
          ["Lists", "/ui/lists/"]
          ["Notification", "/ui/notification/"]
          ["Tabs", "/ui/tabs/"]
          ["Carousels", "/ui/carousels/"]
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
      this.list.destroy()
      this.nav.destroy()
      this.view.destroy()
      super

  UIView: UIView
