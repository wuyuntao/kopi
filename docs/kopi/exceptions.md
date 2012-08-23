# Some common exceptions for Kopi

## Exception

Base class of all exceptions.

```coffeescript
throw new Exception("Some exception")
```


## NoSuchElementError

Error raised when HTML element can not be found.

```coffeescript
element = $("#container")
throw new NoSuchElementError(element) unless element.length
```


## NotImplementedError

Error raised when a method is not ready to use.


## ValueError

Error raised when value is not correct.


## SingletonError

Error raised when a singleton class initialized more than once.

```coffeescript
class Viewport

  # Reference of singleton instance
  this.instance = null

  constructor: ->
    cls = this.constructor
    throw new SingletonError(cls) if cls.instance
    cls.instance = this
```

