define "kopi/tests/logging", (require, exports, module) ->

  q = require "qunit"
  logging = require "kopi/logging"

  q.module "kopi/logging"

  q.test "default logger", ->
    logging.log "log message", [1, 2, 3]
    logging.info "info message", key: 'value'
    logging.warn "warn message", "Help!"
    logging.error "error message", new Error("Something is Wrong")
    q.ok true

  q.test "time metrics", ->
    q.stop()
    logging.time "time"
    setTimeout (->
      logging.timeEnd "time"
      q.ok true
      q.start()
    ), 1000

  q.test "setup logging level", ->
    logger = logging.logger("custom_logger")
    logger.level(logging.WARN)
    logger.log "log message"
    logger.info "info message"
    logger.warn "warn message"
    logger.error "error message"
    q.ok true
