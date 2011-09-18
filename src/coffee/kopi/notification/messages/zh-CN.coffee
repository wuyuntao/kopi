kopi.module("kopi.notification.messages.zh-CN")
  .require("kopi.utils.i18n")
  .define (exports, i18n) ->
    i18n.define "zh-CN"
      notification:
        message:
          title: "对话框"
          action: "确定"
          close: "取消"
          loading_title: "正在载入。。。"
          loading_content: "请稍等片刻。。。"
