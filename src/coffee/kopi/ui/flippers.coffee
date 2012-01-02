kopi.module("kopi.ui.flippers")
  .require("kopi.ui.groups")
  .define (exports, groups) ->

    ###
    A simple animator that will animate between two or more views added to it.

    HTML:

      div.flipper
        div.flipper-child
        div.flipper-child
        div.flipper-child

    ###
    class Flipper extends groups.Group

    exports.Flipper = Flipper
