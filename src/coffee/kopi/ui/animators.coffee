define "kopi/ui/animators", (require, exports, module) ->

  klass = require "kopi/utils/klass"
  switchers = require "kopi/ui/switchers"
  animations = require "kopi/ui/animators/animations"

  class Animator extends switchers.Switcher

    kls = this

    kls.configure
      animationClass: animations.Animation

    klass.accessor this.prototype, "animation"

    constructor: ->
      super
      this._animation = new this._options.animationClass()

    resetAnimation: -> this._animation = null

    _switch: (fromChild, toChild, options) ->
      cls = this.constructor
      self = this
      animateFn = ->
        fromChild.element.removeClass(cls.cssClass("current")) if fromChild
        toChild.element.addClass(cls.cssClass("current"))
        self._currentKey = self._key(toChild)
      self._animation.animate(fromChild, toChild, options, animateFn)
      self

  Animator: Animator
