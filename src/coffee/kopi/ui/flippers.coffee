kopi.module("kopi.ui.flippers")
  .require("kopi.ui.groups")
  .require("kopi.ui.draggable")
  .define (exports, groups, draggable) ->

    class Flippable extends draggable.Draggable

      constructor: (element, options) ->
        super(element, options)

    ###
    A simple animator that will animate between two or more views added to it.

    HTML:

      div.flipper
        div.flipper-child
        div.flipper-child
        div.flipper-child

    ###
    class Flipper extends groups.Group

      this.configure
        childClass: FlipperChild

    exports.FlipperChild = FlipperChild
    exports.Flipper = Flipper
