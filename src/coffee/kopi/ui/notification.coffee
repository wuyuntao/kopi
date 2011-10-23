kopi.module("kopi.ui.notification")
  .require("kopi.utils.i18n")
  .require("kopi.exceptions")
  .require("kopi.ui.notification.bubbles")
  .require("kopi.ui.notification.dialogs")
  .require("kopi.ui.notification.indicators")
  .require("kopi.ui.notification.overlays")
  .define (exports, i18n, exceptions, bubbles, dialogs, indicators, overlays) ->

    ###
    当对话框或其他组建被重复激活时报错
    ###
    class DuplicateNotificationError extends exceptions.Exception

    ###
    显示透明的 overlay
    ###
    lock = -> overlays.overlay.show(true)

    unlock = -> overlays.overlay.hide()

    dialog = (message) ->
      if dialogs.dialog.active
        throw new DuplicateNotificationError(dialogs.dialog)
      dialogs.dialog.message(message)

    ###
    显示 loader
    ###
    loading = -> indicators.indicator.show()

    loaded = -> indicators.indicator.hide()

    # bubble = (text) ->
    #   # TODO 更新消息框，而不是抛出异常
    #   if bubbles.bubble.active
    #     throw new DuplicateNotificationError(bubbles.bubble)
    #   bubbles.bubble.context(text).show()

    exports.lock = lock
    exports.unlock = unlock
    exports.loading = loading
    exports.loaded = loaded
    exports.dialog = dialog
    # exports.bubble = bubble
