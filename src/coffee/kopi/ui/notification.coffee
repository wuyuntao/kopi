define "kopi/ui/notification", (require, exports, module) ->

  i18n = require "kopi/utils/i18n"
  exceptions = require "kopi/exceptions"
  bubbles = require "kopi/ui/notification/bubbles"
  dialogs = require "kopi/ui/notification/dialogs"
  indicators = require "kopi/ui/notification/indicators"
  overlays = require "kopi/ui/notification/overlays"

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

  overlay: overlay
  bubble: bubble
  dialog: dialog
  indicator: indicator
  lock: lock
  unlock: unlock
  loading: loading
  loaded: loaded
  message: message
