kopi.module("kopi.ui.notification.bubbles")
  .require("kopi.utils.i18n")
  .require("kopi.ui.notification.widgets")
  .define (exports, i18n, widgets) ->

    class Bubble extends widgets.Widget

      onskeleton: ->
        this._content = $("p", this.element)
        super

      content: (text) ->
        this._content.text(text)

      show: ->
        cls = this.constructor
        self = this
        slef.element
          .addClass(cls.showClass())
          .removeClass(cls.hideClass())
        slef

      hide: ->
        cls = this.constructor
        self = this
        self.element
          .addClass(cls.hideClass())
          .removeClass(cls.showClass())
        self

    $ -> exports.bubble = new Bubble().skeleton().render()
