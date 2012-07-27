define "kopi/utils/http", (require, exports, module) ->

  $ = require "jquery"
  EventEmitter = require("kopi/events").EventEmitter
  utils = require "kopi/utils"
  klass = require "kopi/utils/klass"
  Map = require("kopi/utils/structs/map").Map

  ###
  `Request` is a wrapper for jQuery.ajax method to work with `RequestQueue`
  ###
  class Request

    @prefix = "request"

    @STATE_PENDING = 0
    @STATE_PROCESSING = 1
    @STATE_SUCCESS = 2
    @STATE_ERROR = 3

    constructor: (@options) ->
      cls = this.constructor
      @guid = @options.guid or utils.guid(cls.prefix)
      @state = cls.STATE_PENDING
      @_request = null
      @_timer = null

    perform: (fn) ->
      cls = this.constructor
      @state = cls.STATE_PROCESSING
      originalSuccessFn = @options.success
      @options.success = (data, text, xhr) =>
        @state = cls.STATE_SUCCESS
        originalSuccessFn(arguments...) if originalSuccessFn
        fn(null, data, text) if fn
      originalErrorFn = @options.error
      @options.error = (xhr, text, error) =>
        @state = cls.STATE_ERROR
        originalErrorFn(arguments...) if originalErrorFn
        fn(error, null, text) if fn

      ajaxFn = =>
        @_request = $.ajax(@options)
        @_timer = null
      if @options.delay
        @timer = setTimeout ajaxFn, @options.delay
      else
        ajaxFn()

    abort: ->
      cls = this.constructor
      return unless @state != cls.STATE_PROCESSING
      if @_request
        @_request.abort()
        @_request = null
      if @_timer
        clearTimeout(@_timer)
        @_timer = null
      @state = cls.STATE_ERROR
      return

  class RequestPool extends Map

    shift: ->
      return if @_keys.length == 0
      key = @_keys.shift()
      value = @_values.shift()
      value

  class ActivePool extends RequestPool

  ###
  Make AJAX requests run in a sequential manner

  TODO Retry when error happens
  ###
  class RequestQueue extends EventEmitter

    @ENQUEUE_EVENT = "enqueue"
    @ABORT_EVENT = "abort"
    @COMPLETE_EVENT = "complete"
    @SUCCESS_EVENT = "success"
    @ERROR_EVENT = "error"
    @EMPTY_EVENT = "empty"

    klass.configure this,
      # @type  {Number} Number of requests can be processing at the same time
      concurrency: 2

    constructor: (options)->
      @configure(options)
      @_pending = new RequestPool()
      @_active = new ActivePool()

    ###
    Add an request to queue
    ###
    enqueue: (request) ->
      return unless request
      # If request is not `Request` instance
      request = new Request(request) unless request instanceof Request
      @_pending.set(request.guid, request)
      @_checkActivePool()
      @emit @constructor.ENQUEUE_EVENT, [request]
      request

    ###
    Remove request from queue
    ###
    abort: (request) ->
      # Remove request from both pending pool and active pool
      request.abort() if request.state == Request.STATE_PROCESSING
      @_pending.remove(request.guid) unless @_active.remove(request.guid)
      @emit @constructor.ABORT_EVENT, [request]
      request

    ###
    Remove all requests from queue
    ###
    abortAll: ->
      @_pending.forEach (request) =>
        @pending.remove(request.guid)
        @emit @constructor.ABORT_EVENT, [request]
      @_active.forEach (request) =>
        request.abort() if request.state == Request.STATE_PROCESSING
        @_active.remove(request.guid)
        @emit @constructor.ABORT_EVENT, [request]
      return

    ###
    To see if active pool is available for new request
    ###
    _checkActivePool: ->
      len = @_active.length()
      if len < @_options.concurrency
        request = @_pending.shift()
        if request
          @_perform(request)
        else if len == 0
          # If no requests are left in both pools, emit an 'empty' event
          @emit @constructor.EMPTY_EVENT

    ###
    To send a request
    ###
    _perform: (request) ->
      cls = this.constructor
      @_active.set(request.guid, request)
      request.perform (error, data, text) =>
        @emit cls.COMPLETE_EVENT, arguments
        @emit (if error then cls.ERROR_EVENT else cls.SUCCESS_EVENT), arguments
        @_active.remove(request.guid)
        @_checkActivePool()

  # Singleton instance of request queue
  queue = new RequestQueue()

  ###
  Provide some high-level wrappers around $.ajax

  ###
  request = (options) ->
    if options.queue == true
      queue.enqueue(options)
    else if options.queue instanceof RequestQueue
      options.queue.enqueue(options)
    else
      $.ajax(options)

  queue: queue
  request: request
  Request: Request
  RequestQueue: RequestQueue
