kopi.module("kopi.ui.notification.dialogs")
  .require("kopi.exceptions")
  .require("kopi.utils.i18n")
  .require("kopi.ui.notification.widgets")
  .require("kopi.ui.notification.overlays")
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

      this.defaults
        title: i18n.t("kopi.notification.messages.title")
        action: i18n.t("kopi.notification.messages.action")
        close: i18n.t("kopi.notification.messages.close")

      title: (title) ->
        this._title.text(title)
        this

      content: (content) ->
        this._content.html(content)
        this

      action: (text, fn) ->
        this._action.text(text) if text
        this.on('action', fn) if $.isFunction(fn)
        this

      close: (text, fn) ->
        this._close.text(text) if text
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
        if not this._content.html().length
          throw new exceptions.ValueError("Missing content of dialog")

        this.active = true
        overlays.overlay.show()
        this.element
          .removeClass('kopi-notification-indicator-hide')
          .addClass('kopi-notification-indicator-show')
        this

      hide: ->
        overlays.overlay.hide()
        this.element
          .addClass('kopi-notification-indicator-hide')
          .removeClass('kopi-notification-indicator-show')
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
        self._title = $('.kopi-notification-dialog-title', self.element)
        self._content = $('.kopi-notification-dialog-content p', self.element)
        self._action = $('.kopi-notification-dialog-action', self.element)
        self._close = $('.kopi-notification-dialog-close', self.element)
        self._action.click (e) -> self.emit('action', [self])
        self._close.click (e) -> self.emit('close', [self])
        self.reset()

      onaction: ->
        this.hide()
        this.reset()

      onclose: ->
        this.hide()
        this.reset()

    # Singleton
    $ -> exports.dialog = new Dialog()
