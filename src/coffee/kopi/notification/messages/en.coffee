kopi.module("kopi.notification.messages.en")
  .require("kopi.utils.i18n")
  .define (exports, i18n) ->
    i18n.define "en"
      kopi:
        notification:
          messages:
            title: "Dialog"
            action: "Confirm"
            close: "Cancel"
            loading_title: "Loading..."
            loading_content: "Please wait a moment..."
