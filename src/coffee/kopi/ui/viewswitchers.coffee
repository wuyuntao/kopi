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

    constructor: ->
      super

    onrender: ->
      viewport.instance().register(this)
      super

  ###
  Widget switcher for views
  ###
  class ViewSwitcher extends Animator

    kls = this
    kls.widgetName "ViewSwitcher"

    kls.POS_NONE = "none"
    kls.POS_TOP = "top"
    kls.POS_TOP_FIXED = "top-fixed"
    kls.POS_BOTTOM = "bottom"
    kls.POS_BOTTOM_FIXED = "bottom-fixed"

    kls.configure
      childClass: View
      # @type  {String} position of navbar
      position: kls.POS_NONE

    constructor: ->
      super
      cls = this.constructor
      options = this._options
      if options.position != cls.POS_NONE
        options.extraClass += " #{cls.cssClass(options.position)}"

    onlock: ->
      app.instance().lock()
      super

    onunlock: ->
      app.instance().unlock()
      super

  View: View
  ViewSwitcher: ViewSwitcher
