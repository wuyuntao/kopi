kopi.module("kopi.ui.buttons")
  .require("kopi.exceptions")
  .require("kopi.utils.klass")
  .require("kopi.ui.images")
  .require("kopi.ui.text")
  .require("kopi.ui.clickable")
  .define (exports, exceptions, klass, images, text, clickable) ->

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

    ###
    A button which does a asynchronic job like AJAX request, or WebSQL request when clicked

    ###
    class AsyncButton extends Button

      kls = this
      kls.JOB_START_EVENT = "jobstart"
      kls.JOB_SUCCEED_EVENT = "jobsucceed"
      kls.JOB_FAIL_EVENT = "jobfail"

      constructor: ->
        super
        cls = this.constructor
        cls.LOAD_CLASS or= cls.cssClass("load")
        cls.SUCCEED_CLASS or= cls.cssClass("succeed")
        cls.FAIL_CLASS or= cls.cssClass("fail")

      onjobstart: ->
        self = this
        cls = this.constructor
        self.element.addClass(cls.LOAD_CLASS)
        doneFn = -> self.emit(cls.JOB_SUCCEED_EVENT, arguments)
        failFn = -> self.emit(cls.JOB_FAIL_EVENT, arguments)
        deferred = this._options.deferredExecute or this._deferredExecute
        if deferred
          deferred().done(doneFn).failFn(failFn)
        else
          (this._options.execute or this._execute)(failFn, doneFn)

      onjobsucceed: ->
        cls = this.constructor
        this.element.removeClass(cls.LOAD_CLASS).addClass(cls.SUCCEED_CLASS)

      onjobfail: ->
        cls = this.constructor
        this.element.removeClass(cls.LOAD_CLASS).addClass(cls.FAIL_CLASS)

      onclick: (e, event) ->
        self = this
        cls = this.constructor
        self.emit(cls.JOB_START_EVENT)
        super

      _execute: (errorFn, successFn) ->
        throw new exceptions.NotImplementedError()

      ###
      Override this method if async job returns a deferred object

      ###
      # _deferredExecute: null


    ###
    A button which does a asynchronic job like AJAX request, or WebSQL request when clicked

    Usage:

      class GetUserButton extends AjaxButton
        this.configure
          url: "/users/1"
          type: "GET"
          dataType: "JSON"

    ###
    class AjaxButton extends AsyncButton

      _deferredExecute: -> $.ajax(this._options)

    exports.Button = Button
    exports.AsyncButton = AsyncButton
    exports.AjaxButton = AjaxButton
