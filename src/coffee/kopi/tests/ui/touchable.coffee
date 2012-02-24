define "kopi/tests/ui/touchable", (require, exports, module) ->

  $ = require "jquery"
  q = require "qunit"
  touchable = require "kopi/ui/touchable"

  class TestTouchable extends touchable.Touchable

  q.module "kopi.ui.touchable"
