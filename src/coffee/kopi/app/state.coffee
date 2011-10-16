kopi.module("kopi.app.state")
  .require("kopi.app.router")
  .require("kopi.events")
  .require("kopi.utils")
  .require("kopi.utils.text")
  .require("kopi.utils.support")
  .require("kopi.exceptions")
  .require("kopi.ui.widgets")
  .require("kopi.ui.views")
  .define (exports, router, events, utils, text, support, exceptions, widgets) ->

    class State
      this.fromJSON = (json={}) ->
        new this(json.url, json.view, json.context, json.uid)

      constructor: (url, view, context={}, id=null) ->
        throw exceptions.ValueError("Must have URL") unless url
        throw exceptions.ValueError("Must have View") unless view and view instanceof views.View

        this.uid = id or utils.uniqueId(this.constructor.name)
        this.url = url
        this.view = view
        this.context = context

      equals: (state) -> this.uid == state.uid

    exports.State = State
