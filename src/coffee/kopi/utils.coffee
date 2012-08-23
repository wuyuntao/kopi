define "kopi/utils", (require, exports, module) ->

  $ = require "jquery"

  ###
  # Common utilities

  ## guid([prefix])

  Generate unique ID.

  `prefix` is a string to make guid more readable. If not specified,
  "kopi" will be used as default.

  ```coffeescript
  class View
    constructor: ->
      cls = this.constructor
      # Generate guid by class name: "view-1"
      this.guid = utils.guid(text.dasherize(cls.name))

  ```

  ###
  counter = 0
  guid = (prefix='kopi') -> prefix + '-' + counter++

  ###
  ## isRegExp(regexp)

  Check if the given value is a regular expression.

  ###
  isRegExp = (obj) -> !!(obj and obj.exec and (obj.ignoreCase or obj.ignoreCase is false))

  guid: guid
  isRegExp: isRegExp
