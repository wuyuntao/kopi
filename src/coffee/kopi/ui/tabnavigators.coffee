define "kopi/ui/tabnavigators", (require, exports, module) ->

  tabs = require "kopi/ui/tabs"
  flippers = require "kopi/ui/flippers"

  ###
  A navigation tabview with a tabbar and a flipper for content
  ###
  class TabNavigator extends widgets.Widget

    kls = this
    kls.configure
      tabBarClass: tabs.TabBar
      flipperClass: flippers.Flipper

    constructor: ->
      super
      self = this
      options = self._options
      self
        .register("tabBar", options.tabBarClass)
        .register("flipper", options.tabBarClass)

  ###
  A navigation tabview with a scrollable tabbar and a flipper for content
  ###
  class ScrollableTabNavigator extends TabNavigator

    kls = this
    kls.configure
      tabBarClass: tabs.ScrollableTabBar
      flipperClass: flippers.Flipper

  TabNavigator: TabNavigator
  ScrollableTabNavigator: ScrollableTabNavigator
