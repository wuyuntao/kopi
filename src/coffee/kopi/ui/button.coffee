kopi.module("kopi.ui.buttons")
  .require("kopi.utils.klass")
  .require("kopi.ui.clickable")
  .define (exports, klass, clickable) ->

    class Button extends clickable.Clickable

      kls = this
      kls.ICON_TOP = 0
      kls.ICON_RIGHT = 1
      kls.ICON_BOTTOM = 2
      kls.ICON_LEFT = 3

      kls.configure
        hasIcon: true
        hasText: true
        iconPos: kls.ICON_LEFT

      proto = kls.prototype
      klass.accessor proto, "text"
      klass.accessor proto, "icon",
        set: (icon) ->
          # TODO Icon must be an instance of Image class
          this._icon = icon
          this

      constructor: (options={}) ->
        super(options)

    exports.Button = Button
