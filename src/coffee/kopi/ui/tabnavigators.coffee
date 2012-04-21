define "kopi/ui/tabnavigators", (require, exports, module) ->

  Widget = require("kopi/ui/widgets").Widget
  tabs = require("kopi/ui/tabs")
  Animator = require("kopi/ui/animators").Animator

  class TabPanel extends Widget

    this.widgetName "TabPanel"

    constructor: (tab, options) ->
      super(options)
      this._tab = tab

  ###
  A navigation tabview with a tabbar and a flipper for content
  ###
  class TabNavigator extends Widget

    kls = this
    kls.TAB_BAR_POS_TOP = "top"
    kls.TAB_BAR_POS_RIGHT = "right"
    kls.TAB_BAR_POS_BOTTOM = "bottom"
    kls.TAB_BAR_POS_LEFT = "left"

    kls.widgetName "TabNavigator"

    kls.configure
      tabBarPos: kls.TAB_BAR_POS_TOP
      tabBarClass: tabs.TabBar
      tabPanelClass: Animator
      tabPanelChildClass: TabPanel

    constructor: ->
      super
      cls = this.constructor
      options = this._options
      if options.tabBarPos
        options.extraClass += " #{cls.cssClass(options.tabBarPos)}"
      if options.tabBarPos == cls.TAB_BAR_POS_TOP or options.tabBarPos == cls.TAB_BAR_POS_LEFT
        this
          .register("tabBar", options.tabBarClass)
          .register("tabPanel", options.tabPanelClass)
      else
        this
          .register("tabPanel", options.tabPanelClass)
          .register("tabBar", options.tabBarClass)

  ###
  A navigation tabview with a scrollable tabbar and a flipper for content
  ###
  class ScrollableTabNavigator extends TabNavigator

    this.widgetName "ScrollableTabNavigator"

    this.configure
      tabBarClass: tabs.ScrollableTabBar

  TabNavigator: TabNavigator
  ScrollableTabNavigator: ScrollableTabNavigator
