define "kopi/demos/views/uilists", (require, exports, module) ->

  View = require("kopi/views").View
  navigation = require("kopi/ui/navigation")
  viewswitchers = require "kopi/ui/viewswitchers"
  reverse = require("kopi/app/router").reverse
  Scrollable = require("kopi/ui/scrollable").Scrollable
  List = require("kopi/ui/lists").List
  ArrayAdapter = require("kopi/ui/lists/adapters").ArrayAdapter
  array = require("kopi/utils/array")

  class UIListView extends View

    constructor: ->
      super
      backButton = new navigation.NavButton
        url: reverse("ui")
        titleText: "Back"
      this.nav = new navigation.Nav
        title: "List"
        leftButton: backButton
      this.view = new viewswitchers.View()

      this.scrollable = new Scrollable
        scrollX: false
      this.list = new List()

    oncreate: ->
      this.app.navBar.add(this.nav)
      this.nav.skeleton()
      this.app.viewSwitcher.add(this.view)
      this.view.skeleton()
      this.scrollable.skeletonTo(this.view.element)
      items = array.map([1..30], ((i) -> "List Item #{i}"))
      this.list
        .adapter(new ArrayAdapter(items))
        .skeletonTo(this.scrollable.container())
      super

    onstart: ->
      this.app.navBar.show(this.nav)
      this.app.viewSwitcher.show(this.view)
      this.nav.render()
      this.view.render()
      this.scrollable.render()
      this.list.render()
      super

    ondestroy: ->
      this.scrollable.destroy()
      this.list.destroy()
      this.nav.destroy()
      this.view.destroy()
      super

  UIListView: UIListView
