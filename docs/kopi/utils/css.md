# CSS utilities

This module provides some helpers to access CSS3 properties.


## experimental(name)

Return a vendor-prefixed CSS property name.

```coffeescript
# return for Chrome: "-webkit-transform"
# return for Firefox: "-moz-transform"
# return for Opera: "-o-transform"
# return for IE: "-ms-transform"
css.experimental("transform")
```


## $.fn.duration(duration)

Set duration for CSS3 transition

## $.fn.translate(x, y)

Move an element along the `x` or `y` axis. Use 3D transform to
enable hardware acceleration if available.


## $.fn.scale(x, y)

Scale an element along the `x` and `y` axis. Use 3D transform to
enable hardware acceleration if available.


## $.fn.parseMatrix()

Parse CSS Matrix from the element

## $.fn.toggleDebug()

Add or remove `kopi-debug` class for element based on configuration.

