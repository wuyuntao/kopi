define "kopi/demos/views/ui", (require, exports, module) ->

  View = require("kopi/views").View
  navigation = require("kopi/ui/navigation")
  viewswitchers = require "kopi/ui/viewswitchers"
  Button = require("kopi/ui/buttons").Button
  ButtonGroup = require("kopi/ui/buttonGroup").ButtonGroup
  NavList = require("kopi/ui/lists").NavList
  Text = require("kopi/ui/text").Text
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

  class UIButtonView extends View

    constructor: ->
      super
      backButton = new navigation.NavButton
        url: reverse("ui")
        titleText: "Back"
      this.nav = new navigation.Nav
        title: "Buttons"
        leftButton: backButton
      this.view = new viewswitchers.View()

    oncreate: ->
      this.app.navBar.add(this.nav)
      this.nav.skeleton()
      this.app.viewSwitcher.add(this.view)
      this.view.skeleton()
      super

    onstart: ->
      this.app.navBar.show(this.nav)
      this.app.viewSwitcher.show(this.view)
      this.nav.render()
      this.view.render()
      super

    ondestroy: ->
      this.nav.destroy()
      this.view.destroy()
      super

  UIView: UIView
  UIButtonView: UIButtonView
