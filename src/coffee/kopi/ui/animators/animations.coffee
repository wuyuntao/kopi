define "kopi/ui/animators/animations", (require, exports, module) ->

  exceptions = require "kopi/exceptions"

  ###
  Interface of animation
  ###
  class Animation

    animate: (from, to, options={}) ->
      throw new exceptions.NotImplementedError()

  Animation: Animation
