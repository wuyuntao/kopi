define "kopi/ui/lists/adapters", (require, exports, module) ->

  array = require "kopi/utils/array"
  events = require "kopi/events"
  queue = require "kopi/utils/structs/queue"

  ###
  Adapter interface
  ###
  class BaseAdapter extends events.EventEmitter

    # constructor: ->
    # forEach: (fn) ->
    # length: ->

  class ArrayAdapter extends BaseAdapter

    constructor: (array=[]) ->
      this._array = array

    forEach: (fn) -> array.forEach(this._array, fn)

    length: -> this._array.length

  class QueueAdapter extends BaseAdapter

    this.CHANGE_EVENT = "change"

    constructor: (queue) ->
      cls = this.constructor
      self = this
      changeFn = (e, obj) ->
        self.emit(cls.CHANGE_EVENT, [obj])
      self._queue = queue
      queue.on(queue.EventQueue.ENQUEUE_EVENT, changeFn)
      queue.on(queue.EventQueue.DNQUEUE_EVENT, changeFn)

    forEach: (fn) ->

    length: -> this._queue.length()

  BaseAdapter: BaseAdapter
  ArrayAdapter: ArrayAdapter
  QueueAdapter: QueueAdapter
