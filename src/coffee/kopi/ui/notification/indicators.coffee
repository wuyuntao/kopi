kopi.module("kopi.ui.notification.indicators")
  .require("kopi.utils.i18n")
  .require("kopi.ui.notification.widgets")
  .require("kopi.ui.notification.overlays")
  .define (exports, i18n, widgets, overlays) ->

    class Indicator extends widgets.Widget

      show: ->
        overlays.overlay.show()
        this.element
          .removeClass('kopi-notification-indicator-hide')
          .addClass('kopi-notification-indicator-show')
        this

      hide: ->
        overlays.overlay.hide()
        this.element
          .addClass('kopi-notification-indicator-hide')
          .removeClass('kopi-notification-indicator-show')
        this

    # Singleton
    $ -> exports.indicator = new Indicator()
