kopi.module("kopi.ui.notification.overlays")
  .require("kopi.settings")
  .require("kopi.utils.i18n")
  .require("kopi.ui.notification.widgets")
  .define (exports, settings, i18n, widgets) ->

    class Overlay extends widgets.Widget

      constructor: ->
        super(settings.kopi.ui.notification.overlay)
        this.element.bind "click", (e) -> return false

      show: (transparent=false) ->
        self = this
        cls = self.constructor
        self.element
          .removeClass(cls.hideClass())
          .addClass(cls.showClass())
        if transparent
          self.element.addClass(cls.transparentClass())
        self

      hide: ->
        self = this
        cls = self.constructor
        self.element
          .addClass(cls.hideClass())
          .removeClass("#{cls.showClass()} #{cls.transparentClass()}")
        self

    # Singleton
    $ -> exports.overlay = new Overlay()
