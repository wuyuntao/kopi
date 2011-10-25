kopi.module("kopi.ui.contents")
  .require("kopi.exceptions")
  .require("kopi.settings")
  .require("kopi.utils")
  .require("kopi.ui.widgets")
  .define (exports, exceptions, settings, utils, widgets) ->

    ###
    视图 和 导航栏 的基类
    ###
    class Content extends widgets.Widget

      constructor: (context) ->
        if not context
          throw new exceptions.ValueError("Must have context")

        # @type {View}
        this.context = context
        super()

      # Helpers to update panel-related states
      for state in ["previous", "current", "next"]
        ((s) => this.prototype[s] = -> this.state("state", s))(state)
      background: -> this.state("state", null)

    exports.Content = Content
