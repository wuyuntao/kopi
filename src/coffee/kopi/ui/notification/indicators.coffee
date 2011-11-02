kopi.module("kopi.ui.notification.indicators")
  .require("kopi.utils.i18n")
  .require("kopi.ui.notification.widgets")
  .require("kopi.ui.notification.overlays")
  .define (exports, i18n, widgets, overlays) ->

    class Indicator extends widgets.Widget

      constructor: ->
        super(settings.kopi.ui.notification.indicator)

      show: ->
        cls = this.constructor
        overlays.overlay.show()
        this.element.removeClass(cls.hideClass()).addClass(cls.showClass())
        this

      hide: ->
        cls = this.constructor
        overlays.overlay.hide()
        this.element.addClass(cls.hideClass()).removeClass(cls.showClass())
        this

    # Singleton
    $ -> exports.indicator = new Indicator()
