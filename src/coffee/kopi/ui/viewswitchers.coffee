define "kopi/ui/viewswitchers", (require, exports, module) ->

  app = require("kopi/app")
  viewport = require("kopi/ui/viewport")
  Widget = require("kopi/ui/widgets").Widget
  Animator = require("kopi/ui/animators").Animator

  ###
  A container of widgets of view
  ###
  class View extends Widget

    this.widgetName "View"

    onrender: ->
      viewport.instance().register(this)
      super

    onresize: ->
      this.element.width(this._end.element.width())
      this.element.height(this._end.element.height())
      super

  ###
  Widget switcher for views
  ###
  class ViewSwitcher extends Animator

    this.widgetName "ViewSwitcher"

    this.configure
      childClass: View

    onlock: ->
      app.instance().lock()
      super

    onunlock: ->
      app.instance().unlock()
      super

  View: View
  ViewSwitcher: ViewSwitcher
