define "kopi/ui/buttons", (require, exports, module) ->

  $ = require "jquery"
  exceptions = require "kopi/exceptions"
  klass = require "kopi/utils/klass"
  Image = require("kopi/ui/images").Image
  Text = require("kopi/ui/text").Text
  Clickable = require("kopi/ui/clickable").Clickable

  ###
  Button

  ###
  class Button extends Clickable

    kls = this
    kls.ICON_POS_TOP = "top"
    kls.ICON_POS_RIGHT = "right"
    kls.ICON_POS_BOTTOM = "bottom"
    kls.ICON_POS_LEFT = "left"
    # kls.ICON_POS_CHOICES = [kls.ICON_TOP, kls.ICON_RIGHT, kls.ICON_BOTTOM, kls.ICON_LEFT]

    kls.widgetName "Button"

    kls.configure
      # @type   {Boolean}   hasIcon   if show icon
      hasIcon: false
      # @type   {Boolean}   hasText   if show text
      hasText: true
      # @type   {Integer}   iconPos   where to put icon
      iconPos: kls.ICON_POS_LEFT
      # @type   {Boolean}   rounded
      rounded: true
      # @type   {String}    cssClass  extra css class added to button
      cssClass: ""
      iconClass: Image
      titleClass: Text
      # @type  {String}     Pre-defined style for buttons, including:
      #                     default, primary, info, success, warning, danger and inverse
      style: "default"
      # @type  {String}     Pre-defined size for buttons, including:
      #                     normal, large, small and mini
      size: "normal"

    proto = kls.prototype
    # TODO Icon must be an instance of Image class
    klass.accessor proto, "icon",
      set: (icon) ->
        this._icon.image(icon) if this._options.hasIcon
        this
    # TODO Text must be an instance of Text class
    klass.accessor proto, "title",
      set: (text) ->
        this._title.text(text) if this._options.hasText
        this

    constructor: (options) ->
      super
      cls = this.constructor
      self = this
      options = self._options
      if options.hasIcon
        iconOptions = self._extractOptions("icon")
        iconOptions.extraClass or= ""
        iconOptions.extraClass += " #{cls.cssClass("icon")}"
        self._icon = new options.iconClass(iconOptions)
      if options.hasText
        titleOptions = self._extractOptions("title")
        titleOptions.extraClass or= ""
        titleOptions.extraClass += " #{cls.cssClass("title")}"
        self._title = new options.titleClass(titleOptions)
      if options.rounded
        options.extraClass += " #{cls.cssClass('rounded')}"
      if options.style
        options.extraClass += " #{cls.cssClass(options.style)}"
      if options.size
        options.extraClass += " #{cls.cssClass(options.size)}"

    onskeleton: ->
      cls = this.constructor
      self = this
      options = self._options
      wrapper = self._ensureWrapper('inner')
      if options.hasIcon
        self._icon.skeletonTo(wrapper)
      if options.hasText
        self._title.skeletonTo(wrapper)
      # When `iconPos` is right or bottom, append icon after text
      #
      # TODO Insert icon element right after initialized
      if options.hasIcon and options.hasText and options.iconPos is cls.ICON_POS_RIGHT or options.iconPos is cls.ICON_BOTTOM
        self._icon.element.insertAfter(self._title.element)
      self.state("icon-pos", options.iconPos)
      super

    onrender: ->
      self = this
      options = self._options
      self._icon.render() if options.hasIcon
      self._title.render() if options.hasText
      super

    onupdate: ->
      self = this
      options = self._options
      self._icon.update() if options.hasIcon
      self._title.update() if options.hasText
      super

    ondestroy: ->
      self = this
      options = self._options
      self._icon.destroy() if options.hasIcon
      self._title.destroy() if options.hasText
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

  Button: Button
  AsyncButton: AsyncButton
  AjaxButton: AjaxButton
