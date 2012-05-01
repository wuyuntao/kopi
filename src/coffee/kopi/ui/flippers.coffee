define "kopi/ui/flippers", (require, exports, module) ->

  logging = require "kopi/logging"
  number = require "kopi/utils/number"
  groups = require "kopi/ui/groups"
  scrollable = require "kopi/ui/scrollable"
  widgets = require "kopi/ui/widgets"

  logger = logging.logger(module.id)

  math = Math

  # DEPRECATED
  # This module is deprecated and should be rewrited later
  # `Flipper` should inherit from `Animator` class

  ###
  Scrollable widget for flipper. Snap to pages
  ###
  class Flippable extends scrollable.Scrollable

    this.widgetName "Flippable"

    this.configure
      snap: true

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
      for page, i in self._flipper.children()
        pageOffset = page.element.position()
        left = - pageOffset.left + wrapperOffset.left
        top = - pageOffset.top + wrapperOffset.top
        self._pagesX[i] = if left < self._maxScrollX then self._maxScrollX else left
        self._pagesY[i] = if top < self._maxScrollY then self._maxScrollY else top

    ###
    Get position where container should snap to

    ###
    _snapPosition: (x, y, duration, reset=false) ->
      self = this
      threshold = self._options.snapThreshold
      distX = x - self._absStartX
      distY = y - self._absStartY
      # TODO 判断速度，而非判断距离
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

  ###
  Child will be added to flipper
  ###
  class Page extends widgets.Widget

    this.widgetName "Page"

  ###
  A simple animator that will animate between two or more views added to it.

  ###
  class Flipper extends groups.Group

    this.widgetName "Flipper"

    this.configure
      childClass: Page
      flippableOptions: {}

    constructor: ->
      super
      self = this
      self._flippable = new Flippable(self, self._options.flippableOptions)

    onskeleton: ->
      this._flippable.skeleton()
        .element.appendTo(this.element)
      super

    onrender: ->
      this._flippable.render()
      super

    ondestroy: ->
      this._flippable.destroy()
      super

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

  Page: Page
  Flipper: Flipper
