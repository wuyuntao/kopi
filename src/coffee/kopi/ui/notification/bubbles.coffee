kopi.module("kopi.ui.notification.bubbles")
  .require("kopi.utils.i18n")
  .require("kopi.ui.notification.widgets")
  .define (exports, i18n, widgets) ->

    class Bubble extends widgets.Widget

    $ -> exports.bubble = new Bubble()
