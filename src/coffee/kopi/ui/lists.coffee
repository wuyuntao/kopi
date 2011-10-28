kopi.module("kopi.ui.lists")
  .require("kopi.ui.widgets")
  .define (exports, widgets) ->

    class List extends widgets.Widget

      append: (item) ->

      prepend: (item) ->

      remove: (item) ->

      skeleton: (item) ->

    class ListItem extends widgets.Widget

    exports.List = List
    exports.ListItem = ListItem
