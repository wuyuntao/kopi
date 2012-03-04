define "kopi/demos/routes", (require, exports, module) ->

  router = require "kopi/app/router"
  views = require "kopi/demos/views"

  router
    .view(views.IndexView).route("/", name: "index").end()

  return
