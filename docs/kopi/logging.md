# Logger

A simple logging library that improve the original console
with timeline and custom tag support.

## Logging levels

Just like `console`, a logger has 4 logging levels in a specific order

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


## Logging

`Logger` has a similar interface to `console` object. But only following
methods are supported: `log`, `info`, `warn`, `error`, `time`, `timeEnd`

```coffeescript
# output: [LOG] [0.027s] [kopi] log message [1, 2, 3]
logger.log "log message", [1, 2, 3]

# output: [INFO] [0.031s] [kopi] info message > Object
logger.info "info message", key: 'value'

# output: [WARN] [0.031s] [kopi] warn message Help!
logger.warn "warn message", "Help!"

# output: [ERROR] [0.031s] [kopi] error message > Error
logger.error "error message", new Error("Something is Wrong")

# output: [LOG] [0.034s] [kopi] time started
logger.time "prof"

# output [LOG] [1.035s] [kopi] time stoped. spent 1001ms.
logger.timeEnd "prof"
```


