kopi.module("kopi.ui.notification.bubbles")
  .require("kopi.utils.i18n")
  .require("kopi.ui.notification.widgets")
  .define (exports, i18n, widgets) ->

    class Bubble extends widgets.Widget

      constructor: (overlay) ->
        super
        this.hidden = true
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

    exports.Bubble = Bubble
