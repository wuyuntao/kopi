define "kopi/ui/animators/animations", (require, exports, module) ->

  klass = require "kopi/utils/klass"
  exceptions = require "kopi/exceptions"

  ###
  Interface of animation
  ###
  class Animation

    klass.configure this,
      duration: 1000

    constructor: (animator, options) ->
      this.animator = animator
      this.configure(options)

    ###
    Main method to animate the UI components
    ###
    animate: (from, to, options={}, fn) ->
      throw new exceptions.NotImplementedError()

  Animation: Animation
