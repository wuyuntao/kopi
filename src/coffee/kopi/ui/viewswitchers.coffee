define "kopi/ui/viewswitchers", (require, exports, module) ->

  widgets = require "kopi/ui/widgets"
  switchers = require "kopi/ui/switchers"

  ###
  A container of widgets of view
  ###
  class View extends widgets.Widget

  ###
  Widget switcher for views
  ###
  class ViewSwitcher extends switchers.Switcher
    this.configure
      childClass: View

  View: View
  ViewSwitcher: ViewSwitcher
