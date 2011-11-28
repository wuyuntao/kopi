kopi.module("kopi.tests.ui.touchable")
  .require("kopi.ui.touchable")
  .define (exports, touchable) ->

    class TestTouchable extends touchable.Touchable

    $ ->

      module "kopi.ui.touchable"
