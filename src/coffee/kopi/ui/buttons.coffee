kopi.module("kopi.ui.buttons")
  .require("kopi.exceptions")
  .require("kopi.utils.klass")
  .require("kopi.ui.images")
  .require("kopi.ui.text")
  .require("kopi.ui.clickable")
  .define (exports, exceptions, klass, images, text, clickable) ->

    ROUND = "round"

    class Button extends clickable.Clickable

      kls = this
      kls.ICON_POS_TOP = "top"
      kls.ICON_POS_RIGHT = "right"
      kls.ICON_POS_BOTTOM = "bottom"
      kls.ICON_POS_LEFT = "left"
      # kls.ICON_POS_CHOICES = [kls.ICON_TOP, kls.ICON_RIGHT, kls.ICON_BOTTOM, kls.ICON_LEFT]

      kls.configure
        # @type   {Boolean}   hasIcon   if show icon
        hasIcon: true
        # @type   {Boolean}   hasText   if show text
        hasText: true
        # @type   {Integer}   iconPos   where to put icon
        iconPos: kls.ICON_POS_LEFT
        # @type   {String}    cssClass  extra css class added to button
        cssClass: ""
        iconClass: images.Image
        iconOptions: {}
        textClass: text.Text
        textOptions: {}

      proto = kls.prototype
      # TODO Icon must be an instance of Image class
      klass.accessor proto, "icon",
        set: (icon) ->
          this._icon.image(icon) if this._options.hasIcon
          this
      # TODO Text must be an instance of Text class
      klass.accessor proto, "text",
        set: (text) ->
          this._text.text(text) if this._options.hasText
          this

      constructor: (options) ->
        super
        cls = this.constructor
        self = this
        options = self._options
        if options.hasIcon
          options.iconOptions.extraClass or= ""
          options.iconOptions.extraClass += " #{cls.cssClass("icon")}"
          self._icon = new options.iconClass(options.iconOptions)
        if options.hasText
          options.textOptions.extraClass or= ""
          options.textOptions.extraClass += " #{cls.cssClass("text")}"
          self._text = new options.textClass(options.textOptions)

      onskeleton: ->
        self = this
        options = self._options
        if options.hasIcon
          self._icon.skeleton()
          self._icon.element.appendTo(self.element)
        if options.hasText
          self._text.skeleton()
          self._text.element.appendTo(self.element)
        self.state("icon-pos", self._options.iconPos)
        super

      onrender: ->
        self = this
        options = self._options
        self._icon.render() if options.hasIcon
        self._text.render() if options.hasText
        super

      onupdate: ->
        self = this
        options = self._options
        self._icon.update() if options.hasIcon
        self._text.update() if options.hasText
        super

    exports.Button = Button
