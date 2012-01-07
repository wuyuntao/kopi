kopi.module("kopi.tests.utils.text")
  .require("kopi.tests.base")
  .require("kopi.utils.text")
  .define (exports, base, text) ->

    module "kopi.utils.text"

    test "pluralize", ->
      equal text.pluralize(''), ''
      equal text.pluralize('goose'), 'geese'
      equal text.pluralize('dolly'), 'dollies'
      equal text.pluralize('genius'), 'genii'
      equal text.pluralize('jones'), 'joneses'
      equal text.pluralize('pass'), 'passes'
      equal text.pluralize('zero'), 'zeros'
      equal text.pluralize('casino'), 'casinos'
      equal text.pluralize('hero'), 'heroes'
      equal text.pluralize('church'), 'churches'
      equal text.pluralize('x'), 'xs'
      equal text.pluralize('car'), 'cars'
