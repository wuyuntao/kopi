kopi.module("kopi.ui.notification.overlays")
  .require("kopi.settings")
  .require("kopi.utils.i18n")
  .require("kopi.ui.notification.widgets")
  .define (exports, settings, i18n, widgets) ->

    class Overlay extends widgets.Widget

      onskeleton: ->
        # TODO Ignore touch events too
        this.element.bind "click", (e) -> return false
        super

      show: (transparent=false) ->
        cls = this.constructor
        self = this
        return self if not self.hidden
        self.hidden = false
        self.element
          .removeClass(cls.hideClass())
          .addClass(cls.showClass())
        self.element.addClass(cls.transparentClass()) if transparent
        self

      hide: ->
        cls = this.constructor
        self = this
        return self if self.hidden
        self.hidden = true
        self.element
          .addClass(cls.hideClass())
          .removeClass("#{cls.showClass()} #{cls.transparentClass()}")
        self

    # Singleton
    exports.Overlay = Overlay
