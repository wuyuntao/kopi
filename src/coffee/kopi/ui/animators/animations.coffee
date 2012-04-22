define "kopi/ui/animators/animations", (require, exports, module) ->

  EventEmitter = require("kopi/events").EventEmitter
  klass = require "kopi/utils/klass"
  exceptions = require "kopi/exceptions"

  ###
  Interface of animation
  ###
  class Animation extends EventEmitter

    kls = this
    klass.configure kls,
      name: "animation"
      duration: 300

    kls.ANIMATION_READY_EVENT = "animationready"
    kls.ANIMATION_START_EVENT = "animationstart"
    kls.ANIMATION_END_EVENT = "animationend"

    constructor: (animator, options) ->
      this.animator = animator
      this.configure(options)

    ###
    Main method to animate the UI components
    ###
    animate: (from, to, options={}, fn) ->
      cls = this.constructor
      self = this
      toClass = to.constructor
      # Show to widget immediately if from widget is not specified
      if not from
        to.element.addClass(toClass.cssClass("show"))
        fn(null) if fn
        return

      isReverse = options.reverse
      animatorClass = self.animator.constructor
      animatorElement = self.animator.element
      fromElement = from.element
      toElement = to.element
      fromStartClass = toClass.cssClass("from-start")
      toStartClass = toClass.cssClass("to-start")
      fromStopClass = toClass.cssClass("from-stop")
      toStopClass = toClass.cssClass("to-stop")
      animationClass = animatorClass.cssClass(self._options.name)
      animationReverseClass = animatorClass.cssClass("#{self._options.name}-reverse")
      # Prepare CSS3 transition
      animatorElement.addClass(animationClass)
      animatorElement.addClass(animationReverseClass) if isReverse
      fromElement.addClass(fromStartClass)
      toElement.addClass(toStartClass)
      self.emit(cls.ANIMATION_READY_EVENT, [from, to, options])

      startTransitionFn = ->
        # Start CSS3 transition
        fromElement.addClass(fromStopClass)
        toElement.addClass(toStopClass)
        self.emit(cls.ANIMATION_START_EVENT, [from, to, options])
        setTimeout(endTransitionFn, self._options.duration + 50)

      endTransitionFn = ->
        self.emit(cls.ANIMATION_END_EVENT, [from, to, options])
        # Make sure transition is complete
        toElement
          .addClass(toClass.cssClass("show"))
          .removeClass("#{toStartClass} #{toStopClass}")
        # A workaround that removes classes `fromElement` a bit later
        # to make sure `toElement` has been shown
        setTimeout (->
          fromElement
            .removeClass(toClass.cssClass("show"))
            .removeClass("#{fromStartClass} #{fromStopClass}")
        ), 50
        animatorElement.removeClass("#{animationClass} #{animationReverseClass}")
        fn(null) if fn

      setTimeout(startTransitionFn, 50)
      self

    # onanimationready: (e, from, to, options) ->
    # onanimationstart: (e, from, to, options) ->
    # onanimationend: (e, from, to, options) ->

  Animation: Animation
