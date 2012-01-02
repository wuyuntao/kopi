kopi.module("kopi.ui.droppable")
  .require("kopi.ui.touchable")
  .define (exports, touchable) ->

    ###
    A widget can be dragged by mouse or finger

    ###
    class Droppable extends touchable.Touchable

    exports.Droppable = Droppable
