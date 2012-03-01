define "kopi/ui/lists/adapters", (require, exports, module) ->

  events = require "kopi/events"
  queue = require "kopi/utils/structs/queue"

  ###
  Adapter interface
  ###
  class BaseAdapter extends events.EventEmitter

    # constructor: ->
    # items: ->
    # length: ->

  class ArrayAdapter extends BaseAdapter

    constructor: (array=[]) ->
      this._array = array

    items: -> this._array

    length: -> this._array.length

  class QueueAdapter extends BaseAdapter

    this.CHANGE_EVENT = "change"

    constructor: (queue) ->
      cls = this.constructor
      self = this
      changeFn = (e, obj) ->
        self.emit(cls.CHANGE_EVENT, [obj])
      self._queue = queue
      queue.on(queue.Queue.ENQUEUE_EVENT, changeFn)
      queue.on(queue.Queue.DNQUEUE_EVENT, changeFn)

    items: -> this._queue

    length: this._queue.length()

  BaseAdapter: BaseAdapter
  ArrayAdapter: ArrayAdapter
  QueueAdapter: QueueAdapter
