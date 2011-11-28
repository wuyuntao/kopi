kopi.module("kopi.tests.ui.touchable")
  .require("kopi.ui.touchable")
  .define (exports, touchable) ->

    class TestTouchable extends touchable.Scrollable

    $ ->

      module "kopi.ui.touchable"
