kopi.module("kopi.ui.navigation")
  .require("kopi.settings")
  .require("kopi.ui.containers")
  .require("kopi.ui.contents")
  .require("kopi.utils.i18n")
  .define (exports, settings, containers, contents, i18n) ->

    ###
    管理 导航栏 的容器
    ###
    class Navbar extends containers.Container

      skeleton: (element) ->
        super
        # Ensure default navbar
        # this.nav = $('.kopi-nav', this.element)
        # if not this.nav.length
        #   this.nav = nav title: i18n.t("loading")
        this.nav = nav title: i18n.t("loading")

    class Nav extends contents.Content

      parts = ["left", "center", "right"]

      skeleton: (element) ->
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

    # A factory method to build typical navigation content
    nav = (element, options) ->
      new Nav(element, options)

    exports.Navbar = Navbar
    exports.Nav = Nav
    exports.nav = nav
