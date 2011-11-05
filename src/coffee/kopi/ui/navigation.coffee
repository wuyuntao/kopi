kopi.module("kopi.ui.navigation")
  .require("kopi.settings")
  .require("kopi.ui.panels")
  .require("kopi.ui.contents")
  .require("kopi.utils")
  .require("kopi.utils.i18n")
  .define (exports, settings, panels, contents, utils, i18n) ->

    ###
    管理 导航栏 的容器
    ###
    class Navbar extends panels.Panel

      skeleton: (element) ->
        super
        # Ensure default navbar
        # this.nav = $('.kopi-nav', this.element)
        # if not this.nav.length
        #   this.nav = nav title: i18n.t("loading")
        # this.nav = nav title: i18n.t("loading")

    class Nav extends contents.Content
      utils.configure this, {}

      parts = ["left", "center", "right"]

      skeleton: ->
        super
        # Ensure element
        self = this
        for part in parts
          ((p) ->
            self[p] = $(".kopi-nav-#{p}", self.element)
            if not self[p].length
              self[p] = $("<div></div>", class: "kopi-nav-#{p}")
                .appendTo(self.element)
          )(part)

        self.title = $('.kopi-nav-title', self.center)
        if not self.title.length
          self.title = $("<h1></h1>", class: "kopi-nav-title")
            .appendTo(self.center)

    exports.Navbar = Navbar
    exports.Nav = Nav
