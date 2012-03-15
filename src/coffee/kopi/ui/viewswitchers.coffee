define "kopi/ui/viewswitchers", (require, exports, module) ->

  Widget = require("kopi/ui/widgets").Widget
  Animator = require("kopi/ui/animators").Animator

  ###
  A container of widgets of view
  ###
  class View extends Widget

  ###
  Widget switcher for views
  ###
  class ViewSwitcher extends Animator
    this.configure
      childClass: View

  View: View
  ViewSwitcher: ViewSwitcher
