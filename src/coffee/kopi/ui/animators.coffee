define "kopi/ui/animators", (require, exports, module) ->

  klass = require "kopi/utils/klass"
  switchers = require "kopi/ui/switchers"
  animations = require "kopi/ui/animators/animations"

  class Animator extends switchers.Switcher

    kls = this

    kls.configure
      animationClass: animations.Animation

    klass.accessor this.prototype, "animation"

    resetAnimation: -> this._animation = null

    _switch: (fromChild, toChild, options) ->
      this._animation or= new this._options.animationClass()
      this._animation.animate(fromChild, toChild, options)
      this

  Animator: Animator
