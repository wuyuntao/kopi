define "kopi/tests/utils", (require, exports, module) ->

  q = require "qunit"
  utils = require "kopi/utils"

  q.module "kopi/utils"

  q.test "guid", ->
    q.equal utils.guid(), "kopi-0"
    q.equal utils.guid("prefix"), "prefix-1"

  q.test "is regexp", ->
    q.equal utils.isRegExp(/^reg/), true
