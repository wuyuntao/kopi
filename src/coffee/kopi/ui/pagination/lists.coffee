kopi.module("kopi.ui.pagination.lists")
  .require("kopi.ui.lists")
  .define (exports, lists) ->

    class PaginationList extends flippers.List

    exports.PaginationList = PaginationList
