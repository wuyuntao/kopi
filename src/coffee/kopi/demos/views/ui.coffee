define "kopi/demos/views/ui", (require, exports, module) ->

  reverse = require("kopi/app/router").reverse
  View = require("kopi/views").View
  navigation = require("kopi/ui/navigation")
  viewswitchers = require "kopi/ui/viewswitchers"
  NavList = require("kopi/ui/lists").NavList
  NavListItem = require("kopi/ui/lists/items").NavListItem

  class UIView extends View

    constructor: ->
      super
      backButton = new navigation.NavButton
        url: reverse("index")
        titleText: "Back"
      @nav = new navigation.Nav
        title: "UI"
        leftButton: backButton
      @view = new viewswitchers.View()
      @list = new NavList()

    oncreate: ->
      @app.navbar.add(@nav)
      @nav.skeleton()
      @app.viewSwitcher.add(@view)
      @view.skeleton()
      widgets = [
        ["Buttons", "/ui/buttons/"]
        ["Controls", "/ui/controls/"]
        ["Lists", "/ui/lists/"]
        ["Notification", "/ui/notification/"]
        ["Tabs", "/ui/tabs/"]
        ["Carousels", "/ui/carousels/"]
      ]
      for widget in widgets
        @list.add new NavListItem(@list, widget)
      @list.skeletonTo(@view.element)
      super

    onstart: ->
      @app.navbar.show(@nav)
      @app.viewSwitcher.show(@view)
      @nav.render()
      @view.render()
      @list.render()
      super

    ondestroy: ->
      @list.destroy()
      @nav.destroy()
      @view.destroy()
      super

  UIView: UIView
