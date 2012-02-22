define "kopi/app/cache", (require, exports, module) ->

  $ = require "jquery"
  logging = require "kopi/logging"
  settings = require "kopi/settings"
  i18n = require "kopi/utils/i18n"
  support = require "kopi/utils/support"
  notification = require "kopi/ui/notification"

  ###
  刷新缓存
  ###
  swapCache = ->
    try
      applicationCache.swapCache() if support.cache
    catch e
      # Do nothing if encounter an INVALID_STATE_ERR error
      logging.error("Failed to swap application cahe. Error: #{e}")

  ###
  重新载入页面

  ###
  reloadPage = ->
    # TODO 提示重新载入页面的信息
    location.reload()

  ###
  弹出提示对话框
  ###
  showDialog = ->
    # TODO 弹出对话框，让用户选择是否要刷新

  onError = (e) ->
    logging.error("Failed to update application cache. Error: #{error}")
    swapCache()

  onUpdateReady = (e) ->
    swapCache()
    if settings.kopi.cache.autoRefresh
      reloadPage()
    else if settings.kopi.cache.notifyRefresh
      showDialog()

  ###
  打开 applicationCache 的事件监听
  ###
  listen = ->
    if support.cache
      $(applicationCache)
        .bind("error", onError)
        .bind("updateready", onUpdateReady)

  listen: listen
