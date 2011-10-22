kopi.module("kopi.ui.navigation")
  .require("kopi.settings")
  .require("kopi.ui.containers")
  .require("kopi.ui.contents")
  .define (exports, settings, containers, contents) ->

    ###
    管理 导航栏 的容器
    ###
    class Navbar extends containers.Container

    class Nav extends contents.Content

    exports.Navbar = Navbar
    exports.Nav = Nav

    exports.nav = (options) ->
