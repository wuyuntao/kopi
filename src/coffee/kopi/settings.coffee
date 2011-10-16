kopi.module("kopi.settings")
  .define (exports) ->
    exports.kopi =
      debug: true

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
        navbar: "#kopi-navbar"
        viewContainer: "#kopi-container"

    exports.extend = ->
      # Deeply extend
      $.extend true, exports, arguments...
