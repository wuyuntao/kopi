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

    constructor: (view, options) ->
      super(options)
      this._view = view
      # TODO Add view name to extra classes

    onrender: ->
      viewport.instance().register(this)
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
