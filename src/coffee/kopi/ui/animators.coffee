kopi.module("kopi.ui.animators")
  .require("kopi.utils.klass")
  .require("kopi.ui.switchers")
  .define (exports, klass, switchers) ->

    class Animator extends switchers.Switcher

      klass.accessor this.prototype, "animation"

      resetAnimation: -> this.animation(null)

      _show: (child) ->

      _hide: (child) ->

    exports.Animator = Animator
