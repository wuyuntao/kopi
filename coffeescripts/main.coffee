define "main", (require, exports, module) ->

  notification = require("kopi/ui/notification")
  DocApp = require("doc/app").DocApp

  notification.loading()
  new DocApp().start()

  return
