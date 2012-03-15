define "kopi/demos/routes", (require, exports, module) ->

  router = require "kopi/app/router"
  views = require "kopi/demos/views"
  ui = require "kopi/demos/views/ui"

  router
    .view(views.IndexView).route("/", name: "index").end()
    .view(ui.UIView).route("/ui/", name: "ui").end()

  return
