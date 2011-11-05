kopi.module("kopi.ui.lists.paginations")
  .require("kopi.ui.lists.items")
  .define (exports, items) ->

    class ListPagination extends items.ListItem

    exports.ListPagination = ListPagination
