kopi.module("kopi.ui.flippers")
  .require("kopi.utils.number")
  .require("kopi.ui.groups")
  .require("kopi.ui.scrollable")
  .require("kopi.ui.widgets")
  .define (exports, number, groups, scrollable, widgets) ->

    math = Math

    ###
    Scrollable widget for flipper. Snap to pages
    ###
    class Flippable extends scrollable.Scrollable

      constructor: (flipper, options) ->
        super(options)
        this._flipper = flipper
        this._currentPageX = 0
        this._currentPageY = 0
        # Make sure snap is set to `true`
        this._options.snap = true
        this._options.momentum = false

      _size: ->
        # TODO Rewrite super._size() method
        super

        self = this
        self._pagesX = []
        self._pagesY = []
        wrapperOffset = self._scroller.position()
        if self._options.snap
          for page, i in self._flipper.children()
            pageOffset = page.element.position()
            left = - pageOffset.left + wrapperOffset.left
            top = - pageOffset.top + wrapperOffset.top
            self._pagesX[i] = if left < self._maxScrollX then self._maxScrollX else left
            self._pagesY[i] = if top < self._maxScrollY then self._maxScrollY else top

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

    ###
    A simple animator that will animate between two or more views added to it.

    ###
    class Flipper extends groups.Group

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

      _wrapper: -> this._flippable.scroller()

    exports.Page = Page
    exports.Flipper = Flipper
