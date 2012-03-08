define "kopi/ui/text", (require, exports, module) ->

  klass = require "kopi/utils/klass"
  widgets = require "kopi/ui/widgets"

  class Text extends widgets.Widget

    kls = this
    kls.configure
      tagName: 'span'

    proto = kls.prototype
    klass.accessor proto, "text",
      set: (text, update=false) ->
        this._text = text
        this.update() if update and this.rendered
        this

    constructor: ->
      super
      this._text or= this._options.text

    onrender: ->
      this._draw()
      super

    _draw: ->
      self = this
      self.element.text(self._text) if self._text

  ###
  A text view support truncate multi-line text
  ###
  class EllipsisText extends Text

    # Text align methods
    this.VALIGN_NONE   = 0
    this.VALIGN_TOP    = 1
    this.VALIGN_BOTTOM = 2
    this.VALIGN_MIDDLE = 3

    this.configure
      tagName: 'p'
      # @type  {Integer} Height of single line
      lineHeight: 18
      # @type  {Integer} Max line for truncated text
      lines: 3
      # @type  {Enum}    Align type
      valign: this.ALIGN_NONE
      # @type  {Integer} Max try to run binary search
      maxTries: 30

    constructor: (element, options, text="") ->
      super(element, options)

      options = this._options
      this._text = text
      this._maxHeight = options.lineHeight * options.lines
      this._fullHeight = null

    onskeleton: (element) ->
      self = this
      options = self._options
      self._maxHeight = options.lineHeight * options.lines
      css =
        overflow: 'hidden'
        lineHeight: options.lineHeight
        maxHeight: self._.maxHeight
      self.element.css(css)
      super

    onrender: ->
      this.update(arguments...)
      super

    onupdate: ->
      self = this
      self._fill()
      self._truncate()
      super

    _fill: ->
      this.element.text(this._text)

    _truncate: ->
      cls = this.constructor
      self = this
      element = this.element
      min = 0
      max = self._text.length - 1
      text = self._text
      # Binary search for find best poistion to truncate text
      for i in [0..self._options.maxTries]
        break if max < min
        middle = Math.floor((min + max) / 2)
        subtext = text.substr(0, middle)
        element.text(subtext + '...')
        height = element.height()
        # Get right row number
        if height > self._maxHeight
          max = middle
        else if height < self._maxHeight
          min = middle
        else
          # Get right column number
          subtext2 = text.substr(0, middle + 1)
          element.text(subtext2 + '...')
          if element.height() > self._maxHeight
            element.text(subtext + '...')
            break
          else
            break if min is middle
            min = middle

    _margin: ->
      self = this
      margin = self._maxHeight - element.height()
      if margin > 0
        switch self._options.valign
          when cls.VALIGN_TOP
            element.css("marginBottom", margin + element.css("marginBottom"))
          when cls.VALIGN_BOTTOM
            element.css("marginTop", margin + element.css("marginTop"))
          when cls.VALIGN_MIDDLE
            margin /= 2
            element.css
              marginTop: margin + element.css("marginTop")
              marginBottom: margin + element.css("marginBottom")
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
