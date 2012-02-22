define "kopi/tests/utils/text", (require, exports, module) ->

  q = require "qunit"
  base = require "kopi/tests/base"
  text = require "kopi/utils/text"

  q.module "kopi.utils.text"

  q.test "pluralize", ->
    q.equals text.pluralize(''), ''
    q.equals text.pluralize('goose'), 'geese'
    q.equals text.pluralize('dolly'), 'dollies'
    q.equals text.pluralize('genius'), 'genii'
    q.equals text.pluralize('jones'), 'joneses'
    q.equals text.pluralize('pass'), 'passes'
    q.equals text.pluralize('zero'), 'zeros'
    q.equals text.pluralize('casino'), 'casinos'
    q.equals text.pluralize('hero'), 'heroes'
    q.equals text.pluralize('church'), 'churches'
    q.equals text.pluralize('x'), 'xs'
    q.equals text.pluralize('car'), 'cars'
