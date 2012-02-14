kopi.module("kopi.settings")
  .require("kopi.exceptions")
  .define (exports, exceptions) ->
    exports.kopi =
      debug: true

      app:
        # @type {Boolean}         Enable task queue for application
        task: false
        # @type  {String}         Start URL of app
        startURL: null
        # @type  {Boolean}        Use pushState for URL change if available
        usePushState: true
        # @type  {Boolean}        Use hashChange for URL change if available
        useHashChange: true
        # @type  {Boolean}        Use interval for URL change if available
        useInterval: true
        # @type {Number}          time to check state change
        interval: 50
        # @type  {Boolean}        Use hash even pushState is available. Good for offline-capable app
        alwaysUseHash: true
        # @type  {Boolean}        Do page redirect if no matched route is found
        redirectWhenNoRouteFound: false

      cache:
        # 是否自动绑定 applicationCache 事件
        enable: false
        # 当 applicationCache 更新成功后，是否自动刷新页面
        autoRefresh: false
        # 当 applicationCache 更新成功后，是否弹出对话框提示用户刷新
        # （仅在 autoRefresh 为 false 的情况下游戏）
        notifyRefresh: false

      i18n:
        # @type {LocaleString}      当前应用使用的语言
        locale: "en"
        # @type {LocaleString}      如果找不到翻译是的默认语言
        fallback: "en"

      logging:
        # 默认的日志等级
        level:    0
        # 是否启用控制台日志
        console:  true
        # # 是否在页面上显示日志（暂不支持）
        # html:     false
        # # 是否数据库记录日志（暂不支持）
        # database: false
        # # 是否向远程服务器发送日志（暂不支持）
        # remote:   false

      ui:
        prefix: "kopi"
        viewport: "body"

        layout:
          navbar: "#kopi-navbar"
          panel: "#kopi-content-panel"

        notification:
          bubble: '#kopi-notification-bubble'
          dialog: '#kopi-notification-dialog'
          dialogTitle: '#kopi-notification-dialog-title'
          dialogContent: '#kopi-notification-dialog-content p'
          dialogAction: '#kopi-notification-dialog-action'
          dialogClose: '#kopi-notification-dialog-close'
          indicator: '#kopi-notification-indicator'
          overlay: '#kopi-notification-overlay'

      native:
        # @type {Boolean} Support Android native interface
        android: true
        # @type {Boolean} Support Chromium native interface
        chromium: true
        # @type {Boolean} Support iOS native interface
        ios: true

      db:
        indexedDB:
          name: "kopi"

    # Read settings from localStorage
    load = ->
      throw new exceptions.NotImplementedError()

    # Save settings to localStorage
    commit = ->
      throw new exceptions.NotImplementedError()

    exports.extend = ->
      # Deeply extend
      $.extend true, exports, arguments...
