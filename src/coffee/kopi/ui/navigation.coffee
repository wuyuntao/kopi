kopi.module("kopi.ui.navigation")
  .require("kopi.settings")
  .require("kopi.ui.containers")
  .require("kopi.ui.widgets")
  .define (exports, settings, containers, widgets) ->

    ###
    管理 导航栏 的容器
    ###
    class Navbar extends containers.Container

    class Nav extends containers.Content

    exports.Navbar = Navbar
    exports.Nav = Nav
