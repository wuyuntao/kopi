define "kopi/ui/notification/dialogs", (require, exports, module) ->

  $ = require "jquery"
  exceptions = require "kopi/exceptions"

  array = require "kopi/utils/array"
  klass = require "kopi/utils/klass"
  text = require "kopi/utils/text"
  i18n = require "kopi/utils/i18n"
  require "kopi/ui/notification/messages/en"
  require "kopi/ui/notification/messages/zh_CN"

  widgets = require "kopi/ui/notification/widgets"
  overlays = require "kopi/ui/notification/overlays"
  EllipsisText = require("kopi/ui/text").EllipsisText
  Button = require("kopi/ui/buttons").Button

  ###
  dialog
    .title("xxx")
    .content("xxx")
    .action("xxx", (event, dialog) ->)
    .close("xxx", (event, dialog) ->)
    .show()

  ###
  class Dialog extends widgets.Widget

    kls = this
    kls.configure
      title: i18n.t("kopi.notification.messages.title")
      action: i18n.t("kopi.notification.messages.action")
      close: i18n.t("kopi.notification.messages.close")

    kls.ACTION_EVENT = "action"
    kls.CLOSE_EVENT = "close"

    proto = kls.prototype
    klass.accessor proto, "title",
      get: -> this._title.text()
      set: (text) -> this._title.text(text)

    klass.accessor proto, "content",
      get: -> this._text.text()
      set: (text) -> this._text.text(text)

    constructor: ->
      super()
      cls = this.constructor
      self = this
      self._overlay = overlays.instance()
      self._title = new EllipsisText
        extraClass: cls.cssClass("title")
        tagName: 'h3'
        lineHeight: 50
        lines: 1
        autoSkeleton: false
      self._text = new EllipsisText
        extraClass: cls.cssClass("text")
        valign: EllipsisText.VALIGN_MIDDLE
        lines: 3
        autoSkeleton: false
      self._action = new Button
        hasIcon: false
        extraClass: cls.cssClass("action")
        style: "primary"
        autoSkeleton: false
        autoRender: false
      self._close = new Button
        hasIcon: false
        extraClass: cls.cssClass("close")
        style: "inverse"
        autoSkeleton: false
        autoRender: false

    onskeleton: ->
      cls = this.constructor
      self = this
      # Ensure dialog parts
      for name in ["gloss", "header", "content", "footer"]
        self["_" + name] = self._ensureWrapper(name)

      # Build skeleton for widgets
      self._title.skeletonTo(self._header)
      self._text.skeletonTo(self._content)
      self._action.skeletonTo(self._footer)
      self._close.skeletonTo(self._footer)

      # Release temp wrapper reference?
      delete self._gloss
      delete self._header
      delete self._content
      delete self._footer

      self.reset()
      super

    onrender: ->
      self = this
      cls = this.constructor
      # Send click events of button to dialog
      self._title.render()
      self._text.render()
      self._action.render().on Button.CLICK_EVENT, -> self.emit cls.ACTION_EVENT
      self._close.render().on Button.CLICK_EVENT, -> self.emit cls.CLOSE_EVENT
      super

    ondestroy: ->
      self = this
      self._title.destroy()
      self._text.destroy()
      self._action.destroy()
      self._close.destroy()
      super

    ###
    Default behaviour when action button is clicked
    ###
    onaction: ->
      this.hide()

    ###
    Default behaviour when close button is clicked
    ###
    onclose: ->
      this.hide()

    message: (message) ->
      self = this
      if typeof message is "string"
        self.content(message)
      else if message
        runFn = (method) -> self[method](message[method]) if method of message
        runFn(method) for method in ["title", "content", "action", "close"]
      self

    action: (text, fn) ->
      cls = this.constructor
      this._action.title(text) if text
      this.off(cls.ACTION_EVENT).on(cls.ACTION_EVENT, fn) if fn
      this

    close: (text, fn) ->
      cls = this.constructor
      this._close.title(text) if text
      this.off(cls.CLOSE_EVENT).on(cls.CLOSE_EVENT, fn) if fn
      this

    ###
    Show dialog

    @param {Hash} options options for bubble

    @option {Boolean} lock if overlay is shown
    @option {Boolean} transparent if overlay is transparent
    ###
    show: (options={}) ->
      if not this._text.text().length
        throw new exceptions.ValueError("Missing content of dialog")

      cls = this.constructor
      self = this
      # Reset previous dialog
      self.hide() if not self.hidden

      self.hidden = false
      self._overlay.show(options.transparent) if options.lock
      self.element.addClass(cls.showClass())
      self

    hide: ->
      cls = this.constructor
      self = this
      return self if self.hidden
      self._overlay.hide()
      self.element.removeClass(cls.showClass())
      self.reset()
      self

    reset: ->
      cls = this.constructor
      self = this
      this.hidden = true
      this
        .title(this._options.title)
        .content("")
        .action(this._options.action)
        .close(this._options.close)
        .off(cls.ACTION_EVENT)
        .off(cls.CLOSE_EVENT)

  # Singleton instance of dialog
  dialogInstance = null

  # Factory method to get singleton instance of dialog
  instance = ->
    dialogInstance or= new Dialog().skeletonTo(document.body).render()

  # A shortcut method to toggle bubble
  show = -> instance().show(arguments...)
  hide = -> instance.hide()

  instance: instance
  show: show
  hide: hide
  Dialog: Dialog
