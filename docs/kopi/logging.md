# Logger

A simple logging library that improve the original console
with timeline and custom tag support.

Just like `console`, a logger has four logging levels in a
specific order.

```
LOG < INFO < WARN < ERROR
```


## Instantiate a logger instance

This module provides a factory method `logging.logger()`
to create loggers.

Multiple calls to `logging.logger()` with the same name will
always return a reference to the same `Logger` instance.

```coffeescript
logging = require 'logging'

# Get default logger
logger = logging.logger()

# Or use default logger directly
logging.log "Say something"

# Get a logger with a custom name
logger = logging.logger('name_of_logger')

# Get a logger with a custom name and high logging level
logger = logging.logger 'name_of_logger',
  level: logging.ERROR
```


## logger.log()

`Logger` has a similar interface to `console` object. But only
following methods are supported: `log`, `info`, `warn`, `error`,
`time`, `timeEnd`.

```coffeescript
# output: [LOG] [0.027s] [kopi] log message [1, 2, 3]
logger.log "log message", [1, 2, 3]
```


## logger.info()

Same as `logger.log()`.

## logger.warn()

Same as `logger.log()`.

## logger.error()

Same as `logger.log()`.

## logger.time(label)

Start a timer

```coffeescript
# output: [LOG] [0.034s] [kopi] time started
logger.time "prof"
```


## logger.timeEnd(label)

Finish timer and record the time spent.

```coffeescript
# output [LOG] [1.035s] [kopi] time stoped. spent 1001ms.
logger.timeEnd "prof"
```


## logger.name()

Return name of logger


## logger.level([level])

Attribute accessor of logging level.

If `level` is not provided, returns current logging level of logger.
If `level` is provided, update current logging level of logger.

```coffeescript
# output: 1
logger.level()

# Increase the logging level
logger.level logging.WARN
# output:  false
logger.info "info message"

# Decrease the logging level
logger.level logging.LOG

# output: [INFO] [0.031s] [kopi] info message
logger.info "info message"
```


