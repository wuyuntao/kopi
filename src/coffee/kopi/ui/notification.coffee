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

    ###
    显示透明的 overlay
    ###
    overlay = ->
      overlayInstance or= new overlays.Overlay().skeleton().render()

    dialog = ->
      overlayInstance or= overlay()
      dialogInstance or= new dialogs.Dialog(overlayInstance).skeleton().render()
      if dialogInstance.active
        throw new DuplicateNotificationError(dialogInstance)
      dialogInstance

    ###
    显示 loader
    ###
    indicator = ->
      overlayInstance or= overlay()
      indicatorInstance or= new indicators.Indicator(overlayInstance).skeleton().render()
      indicatorInstance.show()

    bubble = ->
      overlayInstance or= overlay()
      bubbleInstance or= new bubbles.Bubble(overlayInstance).skeleton().render()

    # Factory methods
    exports.overlay = overlay
    exports.bubble = bubble
    exports.dialog = dialog
    exports.indicator = indicator
