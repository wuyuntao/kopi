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
        this._showClass or= this.constructor.cssClass("show", "notification")
        this._hideClass or= this.constructor.cssClass("hide", "notification")
        this._transparentClass or= this.constructor.cssClass("transparent", "notification")
        this.element
          .removeClass(this._hideClass)
          .addClass(this._showClass)
        this.element.addClass(this._transparentClass) if transparent
        this

      hide: ->
        this._showClass or= this.constructor.cssClass("show", "notification")
        this._hideClass or= this.constructor.cssClass("hide", "notification")
        this._transparentClass or= this.constructor.cssClass("transparent", "notification")
        this.element
          .addClass(this._hideClass)
          .removeClass(this._showClass)
          .removeClass(this._transparentClass)
        this

    # Singleton
    $ -> exports.overlay = new Overlay()
