kopi.module("kopi.tests.ui.scrollable")
  .require("kopi.ui.scrollable")
  .define (exports, scrollable) ->

    class TestScrollable extends scrollable.Scrollable

    $ ->

      module "kopi.ui.scrollable"
