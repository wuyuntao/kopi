kopi.module("kopi.tasks.workers")
  .require("kopi.events")
  .require("kopi.exceptions")
  .require("kopi.logging")
  .require("kopi.utils.structs.queue")
  .require("kopi.utils.text")
  .define (exports, events, exceptions, logging, queue, text) ->

    class TaskError extends exception.Exception

    class Queue extends queue.Queue

      enqueue: (task, data) ->
        if not text.isString(task)
          task = task.toString()
        if not text.isString(data)
          data = JSON.stringify(data)
        super([task, data])


    class Worker extends events.EventEmitter

      constructor: (queue, interval=1000) ->
        this.queue = queue
        this.running = false
        this.interval = interval

      ###
      Public: Tracks the worker in Redis and starts polling.
      ###
      start: ->
        return if this.running
        self = this
        onInterval = -> self._poll()
        this.running = setInterval onInterval, this.interval

      ###
      Public: Stops polling and purges this Worker's stats from Redis.
      ###
      stop: ->
        return unless this.running
        clearInterval this.running
        this.running = false

      ###
      Polls the next queue for a task.
      ###
      _poll: ->
        this.emit "poll", this, this.queue
        unless this.queue.isEmpty()
          [task, data] = this.queue.dequeue()
          try
            this._perform(task, data)
          catch e
            if e instanceof TaskError
              logging.error "TaskError: #{e.message}"
              this.emit "error", [e]
        return

      ###
      Handles the actual running of the task.
      ###
      _perform: (task, data) ->
        self = this
        try
          task = text.constantize(task) if text.isString(task)
        catch e
          throw new TaskError("Task class can not be constantized: #{task}")

        try
          data = JSON.parse(data)
        catch e
          throw new TaskError("Failed to parse task data: #{data}")

        eventData = [self, task, data]
        self.emit "perform", eventData
        task.perform data, (error) ->
          self.emit (if error then "success" else "error"), eventData
        return

    exports.TaskError = TaskError
    exports.Worker = Worker
    exports.Queue = Queue
