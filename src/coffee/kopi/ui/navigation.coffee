define "kopi/ui/navigation", (require, exports, module) ->

  $ = require "jquery"
  settings = require "kopi/settings"
  utils = require "kopi/utils"
  i18n = require "kopi/utils/i18n"
  klass = require "kopi/utils/klass"
  text = require "kopi/utils/text"
  Text = require("kopi/ui/text").Text
  Widget = require("kopi/ui/widgets").Widget
  Animator = require("kopi/ui/animators").Animator
  Animation = require("kopi/ui/animators/animations").Animation

  ###
  A standard navbar with three parts
    1. leftButton: usually provides a backward button
    2. title: usually provides name of view
    3. rightButton: usually provides a tool or config button
  ###
  class Nav extends Widget

    kls = this
    kls.widgetName "Nav"

    proto = kls.prototype
    # Provide a method to remove items from navbar
    defineMethod = (name) ->
      proto["remove" + text.capitalize(name)] = ->
        if this["_#{name}"]
          this["_#{name}"].destroy()
          this["_#{name}"] = null
        this
    # TODO Should we provide a type check for title and buttons?
    for name in ["title", "leftButton", "rightButton"]
      klass.accessor proto, name
      defineMethod name

    constructor: ->
      super
      options = this._options
      this._title = if options.title and text.isString(options.title) then new Text(text: options.title, tagName: 'h1') else options.title
      this._leftButton = options.leftButton
      this._rightButton = options.rightButton

    onskeleton: ->
      # Ensure parts
      for name in ["left", "center", "right"]
        this["_" + name] = this._ensureWrapper(name)
      this._title.skeletonTo(this._center) if this._title
      this._leftButton.skeletonTo(this._left) if this._leftButton
      this._rightButton.skeletonTo(this._right) if this._rightButton
      super

    onrender: ->
      this._title.render() if this._title
      this._leftButton.render() if this._leftButton
      this._rightButton.render() if this._rightButton
      super

    ondestroy: ->
      this._title.destroy() if this._title
      this._leftButton.destroy() if this._leftButton
      this._rightButton.destroy() if this._rightButton
      super

  class NavBarAnimation extends Animation

    this.configure
      duration: 1000

    animate: (from, to, options={}, fn) ->
      cls = to.constructor
      self = this
      # Show to widget immediately if from widget is not specified
      if not from
        to.element.addClass(cls.cssClass("show"))
        fn(null) if fn
        return

      fromElement = from.element
      toElement = to.element
      fromStartClass = cls.cssClass("from-start")
      toStartClass = cls.cssClass("to-start")
      fromStopClass = cls.cssClass("from-stop")
      toStopClass = cls.cssClass("to-stop")
      # Prepare CSS3 transition
      fromElement.addClass(fromStartClass)
      toElement.addClass(toStartClass)

      startTransitionFn = ->
        # Start CSS3 transition
        fromElement.addClass(fromStopClass)
        toElement.addClass(toStopClass)
        setTimeout(endTransitionFn, self._options.duration * 1.5)

      endTransitionFn = ->
        # Make sure transition is complete
        toElement
          .addClass(cls.cssClass("show"))
          .removeClass("#{toStartClass} #{toStopClass}")
        fromElement
          .removeClass(cls.cssClass("show"))
          .removeClass("#{fromStartClass} #{fromStopClass}")

      setTimeout(startTransitionFn, 100)

  ###
  A toolbar manages all navs
  ###
  class Navbar extends Animator

    kls = this
    kls.widgetName "Navbar"

    this.configure
      animationClass: NavBarAnimation

    kls.POS_NONE = "none"
    kls.POS_TOP = "top"
    kls.POS_TOP_FIXED = "top-fixed"
    kls.POS_BOTTOM = "bottom"
    kls.POS_BOTTOM_FIXED = "bottom-fixed"

    kls.configure
      childClass: Nav
      # @type  {String} position of navbar
      position: kls.POS_NONE

    constructor: ->
      super
      cls = this.constructor
      options = this._options
      if options.position != cls.POS_NONE
        options.extraClass += " #{cls.cssClass(options.position)}"

  Navbar: Navbar
  Nav: Nav
