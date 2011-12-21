kopi.module("kopi.ui.notification.dialogs")
  .require("kopi.exceptions")
  .require("kopi.utils.i18n")
  .require("kopi.ui.notification.widgets")
  .require("kopi.ui.notification.overlays")
  .require("kopi.ui.notification.messages.en")
  .require("kopi.ui.notification.messages.zh_CN")
  .define (exports, exceptions, i18n, widgets, overlays) ->

    ###
    kopi.notification.dialog()
        .title("xxx")
        .content("xxx")
        .action("xxx", (event, dialog) ->)
        .close("xxx", (event, dialog) ->)
        .show()

    ###
    class Dialog extends widgets.Widget

      this.configure
        title: i18n.t("kopi.notification.messages.title")
        action: i18n.t("kopi.notification.messages.action")
        close: i18n.t("kopi.notification.messages.close")

      title: (title) ->
        this.element.title.text(title)
        this

      content: (content) ->
        this.element.content.html(content)
        this

      action: (text, fn) ->
        this.element.action.text(text) if text
        this.on('action', fn) if $.isFunction(fn)
        this

      close: (text, fn) ->
        this.element.close.text(text) if text
        this.on('close', fn) if $.isFunction(fn)
        this

      message: (message) ->
        self = this
        if typeof message is "string"
          self.content(message)
        else
          for method in ["title", "content", "action", "close"]
            ((m) -> self[m](message[m]) if m of message)(method)
        self

      show: ->
        if not this.element.content.html().length
          throw new exceptions.ValueError("Missing content of dialog")

        cls = this.constructor
        this.active = true
        overlays.overlay.show()
        this.element
          .removeClass(cls.hideClass())
          .addClass(cls.showClass())
        this

      hide: ->
        cls = this.constructor
        overlays.overlay.hide()
        this.element
          .addClass(cls.hideClass())
          .removeClass(cls.showClass())
        this.reset()
        this

      reset: ->
        this.active = false
        this
          .title(this._options.title)
          .content("")
          .action(this._options.action)
          .close(this._options.close)
          .off('action')
          .off('close')

      skeleton: ->
        super
        self = this
        self.element.title = $('.kopi-notification-dialog-title', self.element)
        self.element.content = $('.kopi-notification-dialog-content p', self.element)
        self.element.action = $('.kopi-notification-dialog-action', self.element)
        self.element.close = $('.kopi-notification-dialog-close', self.element)
        self.element.action.click (e) -> self.emit('action', [self])
        self.element.close.click (e) -> self.emit('close', [self])
        self.reset()

      onaction: ->
        this.hide()
        this.reset()

      onclose: ->
        this.hide()
        this.reset()

    # Singleton
    $ -> exports.dialog = new Dialog()
