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

    # Notification widget instances (singleton)
    bubbleInstance = null
    dialogInstance = null
    indicatorInstance = null
    overlayInstance = null

    overlay = ->
      overlayInstance or= new overlays.Overlay().skeleton().render()

    dialog = ->
      overlayInstance or= overlay()
      dialogInstance or= new dialogs.Dialog(overlayInstance).skeleton().render()
      dialogInstance

    indicator = ->
      overlayInstance or= overlay()
      indicatorInstance or= new indicators.Indicator(overlayInstance).skeleton().render()

    bubble = ->
      overlayInstance or= overlay()
      bubbleInstance or= new bubbles.Bubble(overlayInstance).skeleton().render()

    lock = (transparent=false) ->
      overlay().show(transparent)

    unlock = ->
      overlay().hide()

    loading = (transparent=false) ->
      indicator().show(transparent)

    loaded = ->
      indicator().hide()

    message = (text) ->
      bubble().content(text).show()

    # Factory methods
    exports.overlay = overlay
    exports.bubble = bubble
    exports.dialog = dialog
    exports.indicator = indicator

    # Shortcut methods
    exports.lock = lock
    exports.unlock = unlock
    exports.loading = loading
    exports.loaded = loaded
    exports.message = message
