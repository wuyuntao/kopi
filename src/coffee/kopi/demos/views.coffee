define "kopi/demos/views", (require, exports, module) ->

  views = require "kopi/views"
  NavList = require("kopi/ui/lists").NavList
  NavListItem = require("kopi/ui/lists/items").NavListItem
  navigation = require "kopi/ui/navigation"
  viewswitchers = require "kopi/ui/viewswitchers"
  settings = require "kopi/demos/settings"
  Text = require("kopi/ui/text").Text

  class IndexView extends views.View

    constructor: ->
      super
      @nav = new navigation.Nav(title: "Index")
      @view = new viewswitchers.View()
      @list = new NavList()

    oncreate: ->
      @app.navbar.add(@nav)
      @nav.skeleton()

      @app.viewSwitcher.add(@view)
      @view.skeleton()

      categories = [
        ["App", "/app/"]
        ["Model", "/model/"]
        ["View", "/view/"]
        ["UI", "/ui/"]
      ]
      for category in categories
        @list.add new NavListItem(@list, category)
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
      @nav.destroy()
      @view.destroy()
      @list.destroy()
      super

  IndexView: IndexView
