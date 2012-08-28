# Function utilities
#

## isFunction(fn)

Is the given value a function?

```coffeescript
# return: true
func = require "kopi/utils/func"
func.isFunction(-> console.log("This is a function."))

