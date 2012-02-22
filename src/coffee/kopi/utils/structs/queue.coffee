define "kopi/utils/structs/queue", (require, exports, module) ->

  array = require "kopi/utils/array"

  ###
  Class for FIFO Queue data structure.

  ###
  class Queue

    ###
    @constructor
    ###
    constructor: ->
      this._queue = []

    enqueue: (obj) -> this._queue.push(obj)

    dequeue: -> this._queue.shift()

    isEmpty: -> array.isEmpty this._queue

  Queue: Queue
