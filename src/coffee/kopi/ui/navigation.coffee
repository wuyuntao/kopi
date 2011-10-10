kopi.module("kopi.ui.navigation")
  .require("kopi.settings")
  .require("kopi.ui.container")
  .require("kopi.ui.widgets")
  .define (exports, settings, container, widgets) ->

    ###
    管理 导航栏 的容器
    ###
    class NavContainer extends container.Container

    class Nav extends widgets.Widget
