define "kopi/ui/navigation", (require, exports, module) ->

  $ = require "jquery"
  settings = require "kopi/settings"
  widgets = require "kopi/ui/widgets"
  switchers = require "kopi/ui/switchers"
  utils = require "kopi/utils"
  i18n = require "kopi/utils/i18n"

  ###
  A toolbar manages all navs
  ###
  class Navbar extends switchers.Switcher

    # onskeleton: ->
    #   super
      # Ensure default navbar
      # this.nav = $('.kopi-nav', this.element)
      # if not this.nav.length
      #   this.nav = nav title: i18n.t("loading")
      # this.nav = nav title: i18n.t("loading")

  class Nav extends widgets.Widget

    this.configure

    parts = ["left", "center", "right"]

    # skeleton: ->
    #   super
    #   # Ensure element
    #   self = this
    #   for part in parts
    #     ((p) ->
    #       self[p] = $(".kopi-nav-#{p}", self.element)
    #       if not self[p].length
    #         self[p] = $("<div></div>", class: "kopi-nav-#{p}")
    #           .appendTo(self.element)
    #     )(part)

    #   self.title = $('.kopi-nav-title', self.center)
    #   if not self.title.length
    #     self.title = $("<h1></h1>", class: "kopi-nav-title")
    #       .appendTo(self.center)

  Navbar: Navbar
  Nav: Nav
