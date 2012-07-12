define "kopi/ui/notification/bubbles", (require, exports, module) ->

  klass = require "kopi/utils/klass"
  widgets = require "kopi/ui/notification/widgets"
  overlays = require "kopi/ui/notification/overlays"
  text = require "kopi/ui/text"

  class Bubble extends widgets.Widget

    this.widgetName "Bubble"

    constructor: ->
      super()
      this._timer = null
      this._overlay = overlays.instance()
      this.register "content", text.EllipsisText,
        valign: text.EllipsisText.VALIGN_MIDDLE

    ###
    Update text in bubble
    ###
    text: (text) ->
      this._content.text(text, true)
      this

    ###
    Show bubble

    @param {String} message text to show in the bubble
    @param {Hash} options options for bubble

    @option {Boolean} lock if overlay is shown
    @option {Boolean} transparent if overlay is transparent
    @option {Integer) duration bubble should disapper automatically
    ###
    show: (message="", options={}) ->
      cls = this.constructor
      self = this
      self.hide() if not self.hidden
      self.hidden = false
      self._overlay.show(options.transparent) if options.lock
      self._content.text(message, true)
      self.element.addClass(cls.showClass())
      if options.duration
        hideFn = ->
          self.hide()
          self._timer = null
        self._timer = setTimeout(hideFn, options.duration)
      self

    ###
    Hide bubble
    ###
    hide: ->
      cls = this.constructor
      self = this
      return self if self.hidden
      self.hidden = true
      self._overlay.hide()
      self.element.removeClass(cls.showClass())
      if self._timer
        clearTimeout(self._timer)
        self._timer = null
      self

  # Singleton instance of bubble
  bubbleInstance = null

  # Factory method to get singleton instance of bubble
  instance = ->
    bubbleInstance or= new Bubble().skeletonTo(document.body).render()

  # A shortcut method to toggle bubble
  show = -> instance().show(arguments...)
  hide = -> instance.hide(arguments...)

  instance: instance
  show: show
  hide: hide
  Bubble: Bubble
