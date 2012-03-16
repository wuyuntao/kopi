define "kopi/ui/animators/animations", (require, exports, module) ->

  klass = require "kopi/utils/klass"
  exceptions = require "kopi/exceptions"

  ###
  Interface of animation
  ###
  class Animation

    klass.configure this,
      duration: 500

    constructor: (animator, options) ->
      this.animator = animator
      this.configure(options)

    ###
    Main method to animate the UI components
    ###
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
        fn(null) if fn

      setTimeout(startTransitionFn, 100)
      self

  Animation: Animation
