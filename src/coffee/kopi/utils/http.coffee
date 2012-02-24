define "kopi/utils/http", (require, exports, module) ->

  $ = require "jquery"
  logging = require "kopi/logging"

  logger = logging.logger(module.id)

  ###
  Provide some high-level wrappers around $.ajax

  TODO Retry when error happens
  TODO Add Delayed requests to task queue
  ###
  request = (options) ->
    $.ajax(options)

  request: request
