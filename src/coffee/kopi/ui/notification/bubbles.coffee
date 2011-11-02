kopi.module("kopi.ui.notification.bubbles")
  .require("kopi.utils.i18n")
  .require("kopi.ui.notification.widgets")
  .define (exports, i18n, widgets) ->

    class Bubble extends widgets.Widget

      content: (text) ->
        this.element.content.text(text)

      skeleton: ->
        super
        self = this
        self.element.content = $("p", self.element)

      show: ->
        cls = this.constructor
        this.element
          .addClass(cls.showClass())
          .removeClass(cls.hideClass())
        this

      hide: ->
        cls = this.constructor
        this.element
          .addClass(cls.hideClass())
          .removeClass(cls.showClass())
        this

    $ -> exports.bubble = new Bubble()
