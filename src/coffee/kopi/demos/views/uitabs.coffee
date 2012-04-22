define "kopi/demos/views/uitabs", (require, exports, module) ->

  View = require("kopi/views").View
  navigation = require("kopi/ui/navigation")
  viewswitchers = require "kopi/ui/viewswitchers"
  reverse = require("kopi/app/router").reverse
  TabNavigator = require("kopi/ui/tabnavigators").TabNavigator
  TabPanel = require("kopi/ui/tabnavigators").TabPanel
  Tab = require("kopi/ui/tabs").Tab
  templates = require("kopi/demos/templates/uitabs")

  class UITabView extends View

    constructor: ->
      super
      backButton = new navigation.NavButton
        url: reverse("ui")
        titleText: "Back"
      this.nav = new navigation.Nav
        title: "Tabs"
        leftButton: backButton
      this.view = new viewswitchers.View
      tab1 = new Tab(titleText: "Tab #1", iconSrc: "/images/kopi/plus.png").key('tab1')
      tab2 = new Tab(titleText: "Tab #2", iconSrc: "/images/kopi/plus.png").key('tab2')
      tab3 = new Tab(titleText: "Tab #3", iconSrc: "/images/kopi/plus.png").key('tab3')
      tab4 = new Tab(titleText: "Tab #4", iconSrc: "/images/kopi/plus.png").key('tab4')
      tab5 = new Tab(titleText: "Tab #5", iconSrc: "/images/kopi/plus.png").key('tab5')
      panel1 = new TabPanel(template: templates.tabPanel1).key("tab1")
      panel2 = new TabPanel(template: templates.tabPanel2).key("tab2")
      panel3 = new TabPanel(template: templates.tabPanel3).key("tab3")
      panel4 = new TabPanel(template: templates.tabPanel4).key("tab4")
      panel5 = new TabPanel(template: templates.tabPanel5).key("tab5")
      this.tabNavigator = new TabNavigator(tabBarPos: TabNavigator.TAB_BAR_POS_BOTTOM)
        .addTab(tab1)
        .addTab(tab2)
        .addTab(tab3)
        .addTab(tab4)
        .addTab(tab5)
        .addPanel(panel1)
        .addPanel(panel2)
        .addPanel(panel3)
        .addPanel(panel4)
        .addPanel(panel5)

    oncreate: ->
      this.app.navBar.add(this.nav)
      this.nav.skeleton()
      this.app.viewSwitcher.add(this.view)
      this.view.skeleton()
      this.tabNavigator.skeletonTo(this.view.element)
      super

    onstart: ->
      this.app.navBar.show(this.nav)
      this.app.viewSwitcher.show(this.view)
      this.nav.render()
      this.view.render()
      this.tabNavigator.render()
      super

    ondestroy: ->
      this.tabNavigator.destroy()
      this.nav.destroy()
      this.view.destroy()
      super

  UITabView: UITabView
