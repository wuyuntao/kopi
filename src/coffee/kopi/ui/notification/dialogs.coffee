kopi.module("kopi.ui.notification.dialogs")
  .require("kopi.utils.i18n")
  .require("kopi.ui.notification.widgets")
  .define (exports, i18n, widgets) ->

    class Dialog extends widgets.Widget

    $ -> exports.dialog = new Dialog()
