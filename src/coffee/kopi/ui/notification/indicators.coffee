kopi.module("kopi.ui.notification.indicators")
  .require("kopi.settings")
  .require("kopi.utils.i18n")
  .require("kopi.ui.notification.widgets")
  .require("kopi.ui.notification.overlays")
  .define (exports, settings, i18n, widgets, overlays) ->

    class Indicator extends widgets.Widget

      constructor: (overlay) ->
        super()
        this._overlay = overlay

      show: ->
        cls = this.constructor
        self = this
        return self if not self.hidden
        self.hidden = false
        self._overlay.show()
        self.element.removeClass(cls.hideClass()).addClass(cls.showClass())
        self

      hide: ->
        cls = this.constructor
        self = this
        return self if self.hidden
        self.hidden = true
        self._overlay.hide()
        self.element.addClass(cls.hideClass()).removeClass(cls.showClass())
        self

    exports.Indicator = Indicator
