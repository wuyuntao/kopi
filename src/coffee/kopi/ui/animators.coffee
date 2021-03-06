define "kopi/ui/animators", (require, exports, module) ->

  klass = require "kopi/utils/klass"
  switchers = require "kopi/ui/switchers"
  animations = require "kopi/ui/animators/animations"

  class Animator extends switchers.Switcher

    kls = this

    kls.widgetName "Animator"

    kls.configure
      animationClass: animations.Animation

    klass.accessor this.prototype, "animation"

    constructor: ->
      super
      this._animation = new this._options.animationClass(this, this._extractOptions("animation"))

    resetAnimation: -> this._animation = null

    _switch: (fromChild, toChild, options) ->
      cls = this.constructor
      self = this
      animateFn = ->
        fromChild.element.removeClass(cls.cssClass("current")) if fromChild
        toChild.element.addClass(cls.cssClass("current"))
        self._currentKey = self._key(toChild)
        self.unlock()

      self.lock()
      self._animation.animate(fromChild, toChild, options, animateFn)
      self

    _appendChild: (child) ->
      # TODO Provide layout animation like Android
      super

  Animator: Animator
