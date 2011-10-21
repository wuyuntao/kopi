kopi.module("kopi.ui.notification")
  .require("kopi.utils.i18n")
  .require("kopi.exceptions")
  .require("kopi.ui.notification.bubbles")
  .require("kopi.ui.notification.dialogs")
  .require("kopi.ui.notification.indicators")
  .require("kopi.ui.notification.overlays")
  .define (exports, i18n, exceptions, bubbles, dialogs, indicators, overlays) ->
    # TODO Better API
    # kopi.notification.loading()
    #     .done()
    #
    # kopi.notification.dialog()
    #     .title("xxx")
    #     .content("xxx")
    #     .on('action', (dialog, callback) ->)
    #     .on('close', (dialog, callback) ->)
    #     .show()
    #     .hide()
    #
    # kopi.notification.alert("text")
    #     .on('close', (dialog, callback) ->)
    #     .show()
    #     .hide()

    ###
    消息
    ###
    class Message
      constructor: (@title=i18n.t("kopi.notification.messages.title")
        , @content
        , @action=i18n.t("kopi.notification.messages.action")
        , @close=i18n.t("kopi.notification.messages.close")
        , @data={}) ->
          throw new Error("Missing content of message") unless this.content

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
      # TODO 更新对话框，而不是抛出异常
      if dialogs.dialog.active
        throw new DuplicateNotificationError(dialogs.dialog)
      dialogs.dialog.context(message)

    alert = (message) ->
      # TODO 更新对话框，而不是抛出异常
      if dialogs.dialog.active
        throw new DuplicateNotificationError(dialogs.dialog)
      dialogs.dialog.context(message)

    ###
    显示 loader
    ###
    loading = -> indicators.indicator.show()

    loaded = -> indicators.indicator.hide()

    bubble = (text) ->
      # TODO 更新消息框，而不是抛出异常
      if bubbles.bubble.active
        throw new DuplicateNotificationError(bubbles.bubble)
      bubbles.bubble.context(text).show()

    exports.lock = lock
    exports.unlock = unlock
    exports.loading = loading
    exports.loaded = loaded
    exports.dialog = dialog
    exports.alert = alert
    exports.bubble = bubble

    ###
    通知
    ###
    # class Notifier

    #   overlay = null
    #   dialog = null
    #   indicator = null
    #   message = null

    #   overlayShow = false
    #   dialogShow = false
    #   indicatorShow = false

    #   showOverylay = ->
    #     overlay
    #       .removeClass('kopi-notification-overlay-hide')
    #       .addClass('kopi-notification-overlay-show')

    #   hideOverlay = ->
    #     overlay
    #       .addClass('kopi-notification-overlay-hide')
    #       .removeClass('kopi-notification-overlay-show')

    #   ###
    #   显示图标
    #   ###
    #   showIndicator = () ->
    #     indicator
    #       .removeClass('kopi-notification-indicator-hide')
    #       .addClass('kopi-notification-indicator-show')
    #     indicatorShow = true
    #     overlayShow = true

    #   hideIndicator = () ->
    #     indicator
    #       .addClass('kopi-notification-indicator-hide')
    #       .removeClass('kopi-notification-indicator-show')
    #     indicatorShow = false
    #     overlayShow = false

    #   drawDialog = (message) ->
    #     for item in ['title', 'content', 'action', 'close']
    #       dialog[item].text(message[item])

    #   hideDialog = () ->
    #     overlay.removeClass('kopi-notification-overlay-show')
    #     dialog.removeClass('kopi-notification-dialog-show')
    #     dialogShow = false
    #     overlayShow = false
    #     message = null

    #   constructor: ->
    #     # 获取 HTML 元素
    #     $ ->
    #       overlay = $('#kopi-notification-overlay')
    #       dialog = $('#kopi-notification-dialog')
    #       dialog.title = $('.kopi-notification-dialog-title', dialog)
    #       dialog.content = $('.kopi-notification-dialog-content p', dialog)
    #       dialog.action = $('.kopi-notification-dialog-action', dialog)
    #       dialog.close = $('.kopi-notification-dialog-close', dialog)
    #       indicator = $('#kopi-notification-indicator')

    #   ###
    #   显示 Loader
    #   ###
    #   loading: ->
    #     showOverylay()
    #     showIndicator('loading')

    #   ###
    #   隐藏 Indicator
    #   ###
    #   hide: ->
    #     hideOverlay()
    #     hideIndicator()

    #   ###
    #   显示对话框

    #   ###
    #   dialog: (options) ->
    #     self = this
    #     message = new Message(options.title, options.content, options.action, options.close)

    #     # TODO 合并 onAction 和 onClose 方法？
    #     # TODO 允许异步回调方法，如 onClose(message, callback) -> ？
    #     # TODO 用户点击按钮后，是否自动出现 Loader？
    #     #
    #     # 不要采用异步方法的一个理由，用户点击按钮后应该立刻有一个响应
    #     onAction = (e) ->
    #       if $.isFunction(options.onAction)
    #         return if options.onAction(message) is false
    #       hideDialog()

    #     onClose = (e) ->
    #       if $.isFunction(options.onClose)
    #         return if options.onClose(message) is false
    #       hideDialog()

    #     drawDialog(message)
    #     dialog.action.unbind('click').bind('click', onAction)
    #     dialog.close.unbind('click').bind('click', onClose)
    #     showOverylay()
    #     dialog.addClass('kopi-notifier-dialog-show')
    #     dialogShow = true
    #     overlayShow = true

    #   action: -> dialog.action.trigger('click')

    #   ###
    #   隐藏对话框
    #   ###
    #   close: -> dialog.close.trigger('click')

    # exports.notifier = new Notifier()
