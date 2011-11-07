kopi.module("kopi.utils.structs.queue")
  .require("kopi.utils.array")
  .define (exports, array) ->

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

    exports.Queue = Queue
