kopi.module("kopi.utils.http")
  .define (exports) ->

    ###
    Provide some high-level wrappers around $.ajax

    TODO Retry when error happens
    TODO Add Delayed requests to task queue
    ###
    request = (options) ->
      $.ajax(options)

    exports.request = request
