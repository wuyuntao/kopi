kopi.module("kopi.ui.flippers")
  .require("kopi.ui.groups")
  .define (exports, groups) ->

    class Flipper extends groups.Group

    exports.Flipper = Flipper
