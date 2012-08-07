define "kopi/demos/views/uilists", (require, exports, module) ->

  View = require("kopi/views").View
  navigation = require("kopi/ui/navigation")
  viewswitchers = require "kopi/ui/viewswitchers"
  reverse = require("kopi/app/router").reverse
  Scrollable = require("kopi/ui/scrollable").Scrollable
  List = require("kopi/ui/lists").List
  ListItem = require("kopi/ui/lists/items").ListItem

  class UIListView extends View

    constructor: ->
      super
      backButton = new navigation.NavButton
        url: reverse("ui")
        titleText: "Back"
      @nav = new navigation.Nav
        title: "List"
        leftButton: backButton
      @view = new viewswitchers.View()

      @scrollable = new Scrollable
        scrollX: false
      @list = new List
        striped: true

    oncreate: ->
      @app.navbar.add(@nav)
      @nav.skeleton()
      @app.viewSwitcher.add(@view)
      @view.skeleton()
      @scrollable.skeletonTo(@view.element)
      for i in [1..30]
        @list.add new ListItem(@list, "List Item #{i}")
      @list.skeletonTo(@scrollable.container())
      super

    onstart: ->
      @app.navbar.show(@nav)
      @app.viewSwitcher.show(@view)
      @nav.render()
      @view.render()
      @list.render()
      @scrollable.render()
      super

    ondestroy: ->
      @scrollable.destroy()
      @list.destroy()
      @nav.destroy()
      @view.destroy()
      super

  UIListView: UIListView
