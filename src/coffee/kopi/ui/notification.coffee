kopi.module("kopi.ui.notification")
  .require("kopi.utils.i18n")
  .require("kopi.logging")
  .require("kopi.ui.widgets")
  .define (exports, i18n, logging) ->
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
    通知
    ###
    class Notifier

      overlay = null
      dialog = null
      indicator = null
      message = null

      overlayShow = false
      dialogShow = false
      indicatorShow = false

      showOverylay = ->
        overlay
          .removeClass('kopi-notifier-overlay-hide')
          .addClass('kopi-notifier-overlay-show')

      hideOverlay = ->
        overlay
          .addClass('kopi-notifier-overlay-hide')
          .removeClass('kopi-notifier-overlay-show')

      ###
      显示图标
      ###
      showIndicator = () ->
        indicator
          .removeClass('kopi-notifier-indicator-hide')
          .addClass('kopi-notifier-indicator-show')
        indicatorShow = true
        overlayShow = true

      hideIndicator = () ->
        indicator
          .addClass('kopi-notifier-indicator-hide')
          .removeClass('kopi-notifier-indicator-show')
        indicatorShow = false
        overlayShow = false

      drawDialog = (message) ->
        for item in ['title', 'content', 'action', 'close']
          dialog[item].text(message[item])

      hideDialog = () ->
        overlay.removeClass('kopi-notifier-overlay-show')
        dialog.removeClass('kopi-notifier-dialog-show')
        dialogShow = false
        overlayShow = false
        message = null

      constructor: ->
        # 获取 HTML 元素
        $ ->
          overlay = $('#kopi-notifier-overlay')
          dialog = $('#kopi-notifier-dialog')
          dialog.title = $('.kopi-notifier-dialog-title', dialog)
          dialog.content = $('.kopi-notifier-dialog-content p', dialog)
          dialog.action = $('.kopi-notifier-dialog-action', dialog)
          dialog.close = $('.kopi-notifier-dialog-close', dialog)
          indicator = $('#kopi-notifier-indicator')

      ###
      显示 Loader
      ###
      loading: ->
        showOverylay()
        showIndicator('loading')

      ###
      隐藏 Indicator
      ###
      hide: ->
        hideOverlay()
        hideIndicator()

      ###
      显示对话框

      ###
      dialog: (options) ->
        self = this
        message = new Message(options.title, options.content, options.action, options.close)

        # TODO 合并 onAction 和 onClose 方法？
        # TODO 允许异步回调方法，如 onClose(message, callback) -> ？
        # TODO 用户点击按钮后，是否自动出现 Loader？
        #
        # 不要采用异步方法的一个理由，用户点击按钮后应该立刻有一个响应
        onAction = (e) ->
          if $.isFunction(options.onAction)
            return if options.onAction(message) is false
          hideDialog()

        onClose = (e) ->
          if $.isFunction(options.onClose)
            return if options.onClose(message) is false
          hideDialog()

        drawDialog(message)
        dialog.action.unbind('click').bind('click', onAction)
        dialog.close.unbind('click').bind('click', onClose)
        showOverylay()
        dialog.addClass('kopi-notifier-dialog-show')
        dialogShow = true
        overlayShow = true

      action: -> dialog.action.trigger('click')

      ###
      隐藏对话框
      ###
      close: -> dialog.close.trigger('click')

    exports.notifier = new Notifier()
