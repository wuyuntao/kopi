define "kopi/demos/views/uitabs", (require, exports, module) ->

  View = require("kopi/views").View
  navigation = require("kopi/ui/navigation")
  viewswitchers = require "kopi/ui/viewswitchers"
  reverse = require("kopi/app/router").reverse
  TabNavigator = require("kopi/ui/tabnavigators").TabNavigator
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
      this.tabNavigator = new TabNavigator(tabBarPos: TabNavigator.TAB_BAR_POS_BOTTOM)
        .addTab("tab1", textTitle: "Tab #1", iconSrc: "/images/kopi/icon1.png")
        .addTab("tab2", textTitle: "Tab #2", iconSrc: "/images/kopi/icon2.png")
        .addTab("tab3", textTitle: "Tab #3", iconSrc: "/images/kopi/icon3.png")
        .addTab("tab4", textTitle: "Tab #4", iconSrc: "/images/kopi/icon4.png")
        .addTab("tab5", textTitle: "Tab #5", iconSrc: "/images/kopi/icon5.png")
        .addPanel("tab1", template: templates.tabPanel1)
        .addPanel("tab2", template: templates.tabPanel2)
        .addPanel("tab3", template: templates.tabPanel3)
        .addPanel("tab4", template: templates.tabPanel4)
        .addPanel("tab5", template: templates.tabPanel5)

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
