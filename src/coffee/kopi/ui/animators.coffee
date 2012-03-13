define "kopi/ui/animators", (require, exports, module) ->

  klass = require "kopi/utils/klass"
  switchers = require "kopi/ui/switchers"

  class Animator extends switchers.Switcher

    klass.accessor this.prototype, "animation"

    resetAnimation: -> this.animation(null)

    _show: (child) ->
      super

    _hide: (child) ->
      super

  Animator: Animator
