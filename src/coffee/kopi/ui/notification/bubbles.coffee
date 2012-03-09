define "kopi/ui/notification/bubbles", (require, exports, module) ->

  $ = require "jquery"
  i18n = require "kopi/utils/i18n"
  widgets = require "kopi/ui/notification/widgets"
  overlays = require "kopi/ui/notification/overlays"

  class Bubble extends widgets.Widget

    constructor: (overlay) ->
      super()
      this._overlay = overlay

    onskeleton: ->
      this._content = $("p", this.element)
      super

    content: (text) ->
      this._content.text(text)

    show: (lock=false) ->
      cls = this.constructor
      self = this
      return self if not self.hidden
      self._overlay.show() if lock
      self.hidden = false
      self.element
        .addClass(cls.showClass())
        .removeClass(cls.hideClass())
      self

    hide: ->
      cls = this.constructor
      self = this
      return self if self.hidden
      self.hidden = true
      self._overlay.hide()
      self.element
        .addClass(cls.hideClass())
        .removeClass(cls.showClass())
      self

  # Singleton instance of bubble
  bubbleInstance = null

  instance: ->
    bubbleInstance or= new Bubble(overlays.instance()).skeleton().render()
  Bubble: Bubble
