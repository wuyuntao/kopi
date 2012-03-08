define "kopi/utils/structs/queue", (require, exports, module) ->

  array = require "kopi/utils/array"
  events = require "kopi/events"
  klass = require "kopi/utils/klass"

  ###
  Class for simple FIFO Queue data structure.

  ###
  class Queue

    ###
    @constructor
    ###
    constructor: ->
      this._queue = []

    enqueue: (obj) ->
      this._queue.push(obj)
      this

    dequeue: ->
      this._queue.shift()
      this

    isEmpty: -> array.isEmpty this._queue

    length: -> this._queue.length

    forEach: (fn) -> array.forEach(this._queue, fn, this)

  ###
  Class for FIFO Queue data structure with events.

  ###
  class EventQueue extends events.EventEmitter

    kls = this

    kls.ENQUEUE_EVENT = "enqueue"
    kls.DEQUEUE_EVENT = "dequeue"

    klass.configure this,
      # @type  {Integer} Maxium length of queue. 0 means no limitation
      length: 0
      # @type  {Boolean} Ignore duplicate items
      unique: false

    constructor: ->
      this._queue = []
      this.configure()

    enqueue: (obj) ->
      self = this
      cls = this.constructor
      options = self._options
      if options.unique
        array.remove(self._queue, obj)
      self._queue.push(node)
      if options.length > 0 and self._queue.length > options.length
        self._queue.shift()
      self.emit cls.ENQUEUE_EVENT, [obj]
      self

    dequeue: ->
      self = this
      cls = this.constructor
      obj = self._queue.shift()
      self.emit cls.DEQUEUE_EVENT, [obj]
      obj

    isEmpty: -> array.isEmpty(this._queue)

    length: -> this._queue.length

    forEach: (fn) -> array.forEach(this._queue, fn, this)

  Queue: Queue
  EventQueue: EventQueue
