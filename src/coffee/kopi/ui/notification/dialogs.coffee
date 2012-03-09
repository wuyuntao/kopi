define "kopi/ui/notification/dialogs", (require, exports, module) ->

  $ = require "jquery"
  exceptions = require "kopi/exceptions"
  i18n = require "kopi/utils/i18n"
  widgets = require "kopi/ui/notification/widgets"
  overlays = require "kopi/ui/notification/overlays"
  en = require "kopi/ui/notification/messages/en"
  zh_CN = require "kopi/ui/notification/messages/zh_CN"

  ###
  kopi.notification.dialog()
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

    constructor: (overlay) ->
      super()
      this._overlay = overlay

    title: (title) ->
      this._title.text(title)
      this

    content: (content) ->
      this._content.html(content)
      this

    action: (text, fn) ->
      cls = this.constructor
      this._action.text(text) if text
      this.on(cls.ACTION_EVENT, fn) if fn
      this

    close: (text, fn) ->
      cls = this.constructor
      this._close.text(text) if text
      this.on(cls.CLOSE_EVENT, fn) if fn
      this

    message: (message) ->
      self = this
      if typeof message is "string"
        self.content(message)
      else
        for method in ["title", "content", "action", "close"]
          ((m) -> self[m](message[m]) if m of message)(method)
      self

    show: (lock=false) ->
      if not this._content.html().length
        throw new exceptions.ValueError("Missing content of dialog")

      cls = this.constructor
      self = this
      return self if not self.hidden
      self.hidden = false
      self._overlay.show() if lock
      self.element
        .removeClass(cls.hideClass())
        .addClass(cls.showClass())
      self

    hide: ->
      cls = this.constructor
      self = this
      return self if self.hidden
      self._overlay.hide()
      self.element
        .addClass(cls.hideClass())
        .removeClass(cls.showClass())
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

    onskeleton: ->
      super
      cls = this.constructor
      self = this
      self._title = $('.kopi-notification-dialog-title', self.element)
      self._content = $('.kopi-notification-dialog-content p', self.element)
      self._action = $('.kopi-notification-dialog-action', self.element)
      self._close = $('.kopi-notification-dialog-close', self.element)
      self._action.click (e) -> self.emit(cls.ACTION_EVENT)
      self._close.click (e) -> self.emit(cls.CLOSE_EVENT)
      self.reset()

    onaction: ->
      this.hide()

    onclose: ->
      this.hide()

  # Singleton instance of dialog
  dialogInstance = null

  instance: ->
    dialogInstance or= new Dialog(overlays.instance()).skeleton().render()
  Dialog: Dialog
