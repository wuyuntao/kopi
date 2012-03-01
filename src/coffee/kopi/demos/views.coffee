define "kopi/demos/views", (require, exports, module) ->

  views = require "kopi/views"
  navigation = require "kopi/ui/navigation"
  lists = require "kopi/ui/lists"
  settings = require "kopi/demos/settings"

  class IndexView extends views.View

    constructor: ->
      super
      this.nav = new navigation.Nav()
      this.list = new lists.List()

    oncreate: ->
      self = this
      self.nav.skeleton()
      self.app.navBar.add(self.nav)
      self.list.skeletonTo(self.element)
      self.app.viewSwitcher.add(self)
      super

    onstart: ->
      self = this
      self.nav.render()
      self.app.navBar.show(self.nav)
      self.list.render()
      self.app.viewSwitcher.show(self)
      super

    ondestroy: ->
      self.nav.destroy()
      self.list.destroy()
      super

  IndexView: IndexView
