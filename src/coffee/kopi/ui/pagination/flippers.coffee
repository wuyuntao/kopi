kopi.module("kopi.ui.pagination.flippers")
  .require("kopi.ui.flippers")
  .define (exports, flippers) ->

    class PaginationFlipper extends flippers.Flipper

    exports.PaginationFlipper = PaginationFlipper
