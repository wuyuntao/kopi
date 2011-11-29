kopi.module("kopi.ui.slidable")
  .require("kopi.ui.scrollable")
  .define (exports, scrollable) ->

    class Slidable extends scrollable.Scrollable

    exports.Slidable = Slidable
