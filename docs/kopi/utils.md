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


## isRegExp(regexp)

Check if the given value is a regular expression.


