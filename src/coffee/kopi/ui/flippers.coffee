define "kopi/ui/flippers", (require, exports, module) ->

  logging = require "kopi/logging"
  klass = require "kopi/utils/klass"
  number = require "kopi/utils/number"
  Animator = require("kopi/ui/animators").Animator
  Animation = require("kopi/ui/animators/animations").Animation
  Scrollable = require("kopi/ui/scrollable").Scrollable
  Widget = require("kopi/ui/widgets").Widget

  logger = logging.logger(module.id)

  math = Math

  ###
  Scrollable widget for flipper. Snap to pages
  ###
  class Flippable extends Scrollable

    this.widgetName "Flippable"

    this.configure
      snap: true
      scrollY: false

    constructor: (flipper, options) ->
      super(options)
      self = this
      self._flipper = flipper
      self._currentPageX = 0
      self._currentPageY = 0
      # Make sure snap is set to `true`
      if not self._options.snap
        logger.warn("Make sure option 'snap' is set to true")
        self._options.snap = true

    onresize: ->
      super
      this.pages()

    ###
    Get snapping pages
    ###
    pages: ->
      self = this
      self._pagesX = []
      self._pagesY = []
      wrapperOffset = self._container.position()
      for page, i in this._flipper.children()
        pageOffset = page.element.position()
        left = - pageOffset.left + wrapperOffset.left
        top = - pageOffset.top + wrapperOffset.top
        this._pagesX[i] = if left < this._maxScrollX then this._maxScrollX else left
        this._pagesY[i] = if top < this._maxScrollY then this._maxScrollY else top
      this

    _containerSize: ->
      options = this._options
      flipper = this._flipper
      width = flipper.width()
      height = flipper.height()

      this._containerWidth = if options.scrollX then width * flipper.children().length else this._elementWidth
      this._containerHeight = if options.scrollY then height * flipper.children().length else this._elementHeight

      this._container.width(this._containerWidth)
      this._container.height(this._containerHeight)
      this

    ###
    Get position where container should snap to

    ###
    _snapPosition: (x, y, duration, reset=false) ->
      self = this
      threshold = self._options.snapThreshold
      distX = x - self._absStartX
      distY = y - self._absStartY
      # TODO Detect by speed instead of distance?
      if math.abs(distX) < threshold and math.abs(distY) < threshold
        x = self._absStartX
        y = self._absStartY
        duration = 200
      else
        snap = if reset then self._snap(self._x, self._y) else self._snap(x, y)
        x = snap.x
        y = snap.y
        duration = math.max(snap.time, duration)
      self.scrollTo(math.round(x), math.round(y), duration)

    _snap: (x, y) ->
      self = this
      # Check page X
      [page, i] = number.round(x, self._pagesX)
      if i == self._currentPageX and i > 0 and self._directionX < 0
        i--
        page = self._pagesX[i]

      x = page
      sizeX = math.abs(x - self._pagesX[self._currentPageX])
      sizeX = if sizeX then math.abs(self._x - x) / sizeX * 500 else 0
      self._currentPageX = i

      # Check page Y
      [page, i] = number.round(y, self._pagesY)

      if i == self._currentPageY and i > 0 and self._directionY < 0
        i--
        page = self._pagesY[i]
      y = page
      sizeY = math.abs(y - self._pagesY[self._currentPageY])
      sizeY = if sizeY then math.abs(self._y - y) / sizeY * 500 else 0
      self._currentPageY = i

      # Snap with constant speed (proportional duration)
      time = math.round(math.max(sizeX, sizeY)) or 200

      x: x
      y: y
      time: time

  class FlipperAnimation extends Animation

    constructor: ->
      super
      this._flippable = this.animator.flippable()

    animate: (from, to, options, fn) ->

  ###
  Child will be added to flipper
  ###
  class FlipperPage extends Widget

    this.widgetName "FlipperPage"

    onresize: ->
      flipper = this.end()
      width = flipper.width()
      height = flipper.height()
      this.element.width(width) if width
      this.element.height(height) if height

      super

  ###
  A simple animator that will animate between two or more views added to it.

  ###
  class Flipper extends Animator

    this.widgetName "Flipper"

    this.configure
      childClass: FlipperPage

    proto = this.prototype
    klass.accessor proto, "width"
    klass.accessor proto, "height"

    constructor: ->
      super
      self = this
      self._flippable = new Flippable(self, self._extractOptions("flippable"))

    onskeleton: ->
      this._flippable.skeletonTo(this.element)
      super

    onrender: ->
      this._flippable.render()
      super

    ondestroy: ->
      this._flippable.destroy()
      super

    onresize: ->
      super
      cls = this.constructor
      flippable = this._flippable
      this._width = if flippable.options().scrollX then flippable.element.innerWidth() else '100%'
      this._height = if flippable.options().scrollY then flippable.element.innerWidth() else '100%'
      for page in this._children
        page.emit cls.RESIZE_EVENT
      this._flippable.emit cls.RESIZE_EVENT
      return

    _wrapper: -> this._flippable.container()

    # Recalculate pages when adding or removing child pages
    addAt: ->
      child = super
      this._flippable.pages() if this._flippable.rendered
      child

    removeAt: ->
      super
      this._flippable.pages() if this._flippable.rendered
      this

    empty: ->
      super
      this._flippable.pages() if this._flippable.rendered
      this

  FlipperAnimation: FlipperAnimation
  FlipperPage: FlipperPage
  Flipper: Flipper
