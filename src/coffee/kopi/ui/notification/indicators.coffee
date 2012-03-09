define "kopi/ui/notification/indicators", (require, exports, module) ->

  settings = require "kopi/settings"
  i18n = require "kopi/utils/i18n"
  widgets = require "kopi/ui/notification/widgets"
  overlays = require "kopi/ui/notification/overlays"

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


  # Singleton instance of indicator
  indicatorInstance = null

  instance: ->
    indicatorInstance or= new Indicator(overlays.instance()).skeleton().render()
  Indicator: Indicator
