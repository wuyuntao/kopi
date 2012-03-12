define "kopi/ui/text", (require, exports, module) ->

  klass = require "kopi/utils/klass"
  widgets = require "kopi/ui/widgets"

  class Text extends widgets.Widget

    kls = this
    kls.configure
      tagName: 'span'

    proto = kls.prototype
    klass.accessor proto, "text",
      set: (text, update=true) ->
        this._text = text
        this.update() if update and this.rendered
        this

    constructor: ->
      super
      this._text or= this._options.text

    onrender: ->
      this._draw()
      super

    onupdate: ->
      this._draw()
      super

    _draw: ->
      self = this
      self.element.text(self._text) if self._text
      self

  ###
  A text view support multi-line text truncation
  ###
  class EllipsisText extends Text

    kls = this
    # Text align methods
    kls.VALIGN_NONE   = 0
    kls.VALIGN_TOP    = 1
    kls.VALIGN_BOTTOM = 2
    kls.VALIGN_MIDDLE = 3

    kls.configure
      tagName: 'p'
      # @type  {Integer} Height of single line
      lineHeight: 18
      # @type  {Integer} Max line for truncated text
      lines: 3
      # @type  {Enum}    Align type
      valign: kls.VALIGN_NONE
      # @type  {Integer} Max try to run binary search
      maxTries: 30

    constructor: (options, text="") ->
      super(options)

      options = this._options
      this._text = text
      this._maxHeight = options.lineHeight * options.lines
      this._fullHeight = null

    onskeleton: ->
      self = this
      options = self._options
      self._maxHeight = options.lineHeight * options.lines
      css =
        overflow: 'hidden'
        lineHeight: parseInt(options.lineHeight) + 'px'
        maxHeight: parseInt(self._maxHeight) + 'px'
      self.element.css(css)
      super

    onresize: ->
      this.update()
      super

    onrender: ->
      this.update()
      super

    onupdate: ->
      this._fill()._truncate()._padding()
      super

    _fill: ->
      this.element.css('padding', 0).text(this._text)
      this

    _truncate: ->
      cls = this.constructor
      self = this
      element = this.element
      min = 0
      max = self._text.length - 1
      text = self._text
      # Handle short text
      if element.innerHeight() <= self._maxHeight
        return self

      # Binary search for find best poistion to truncate text
      for i in [0..self._options.maxTries]
        break if max < min
        middle = Math.floor((min + max) / 2)
        subtext = text.substr(0, middle)
        element.text(subtext + '...')
        height = element.innerHeight()
        # Get right row number
        if height > self._maxHeight
          max = middle
        else if height < self._maxHeight
          min = middle
        else
          # Get right column number
          subtext2 = text.substr(0, middle + 1)
          element.text(subtext2 + '...')
          if element.innerHeight() > self._maxHeight
            element.text(subtext + '...')
            break
          else
            break if min is middle
            min = middle
      self

    _padding: ->
      cls = this.constructor
      self = this
      element = self.element
      padding = self._maxHeight - element.innerHeight()
      if padding > 0
        switch self._options.valign
          when cls.VALIGN_TOP
            element.css("paddingBottom", padding + "px")
          when cls.VALIGN_BOTTOM
            element.css("paddingTop", padding + "px")
          when cls.VALIGN_MIDDLE
            padding /= 2
            element.css
              paddingTop: padding + "px"
              paddingBottom: padding + "px"
      self

    # Get height when display full text
    _height: (force=false) ->
      self = this
      element = self.element
      if force or not self._fullHeight
        text = element.text()
        element.text(self.text)
        self._fullHeight = element.height()
        element.text(text)
      self._fullHeight

  Text: Text
  EllipsisText: EllipsisText
