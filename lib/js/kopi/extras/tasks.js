(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/tasks/workers", function(require, exports, module) {
    var Queue, Task, TaskError, Worker, events, exceptions, logging, queue, text, _ref, _ref1;

    events = require("kopi/events");
    exceptions = require("kopi/exceptions");
    logging = require("kopi/logging");
    queue = require("kopi/utils/structs/queue");
    text = require("kopi/utils/text");
    TaskError = (function(_super) {
      __extends(TaskError, _super);

      function TaskError() {
        _ref = TaskError.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      return TaskError;

    })(exception.Exception);
    Queue = (function(_super) {
      __extends(Queue, _super);

      function Queue() {
        _ref1 = Queue.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      Queue.prototype.enqueue = function(task, data) {
        if (!text.isString(task)) {
          task = task.toString();
        }
        if (!text.isString(data)) {
          data = JSON.stringify(data);
        }
        return Queue.__super__.enqueue.call(this, [task, data]);
      };

      return Queue;

    })(queue.Queue);
    Task = (function() {
      function Task() {}

      Task.perform = function(data, fn) {
        throw new exceptions.NotImplementedError();
      };

      return Task;

    })();
    Worker = (function(_super) {
      __extends(Worker, _super);

      function Worker(queue, interval) {
        if (interval == null) {
          interval = 1000;
        }
        this.queue = queue;
        this.running = false;
        this.interval = interval;
      }

      /*
      Public: Tracks the worker in Redis and starts polling.
      */


      Worker.prototype.start = function() {
        var onInterval, self;

        if (this.running) {
          return;
        }
        self = this;
        onInterval = function() {
          return self._poll();
        };
        return this.running = setInterval(onInterval, this.interval);
      };

      /*
      Public: Stops polling and purges this Worker's stats from Redis.
      */


      Worker.prototype.stop = function() {
        if (!this.running) {
          return;
        }
        clearInterval(this.running);
        return this.running = false;
      };

      /*
      Polls the next queue for a task.
      */


      Worker.prototype._poll = function() {
        var data, e, task, _ref2;

        this.emit("poll", this, this.queue);
        if (!this.queue.isEmpty()) {
          _ref2 = this.queue.dequeue(), task = _ref2[0], data = _ref2[1];
          try {
            this._perform(task, data);
          } catch (_error) {
            e = _error;
            if (e instanceof TaskError) {
              logging.error("TaskError: " + e.message);
              this.emit("error", [e]);
            }
          }
        }
      };

      /*
      Handles the actual running of the task.
      */


      Worker.prototype._perform = function(task, data) {
        var e, eventData, self;

        self = this;
        try {
          if (text.isString(task)) {
            task = text.constantize(task);
          }
        } catch (_error) {
          e = _error;
          throw new TaskError("Task class can not be constantized: " + task);
        }
        try {
          data = JSON.parse(data);
        } catch (_error) {
          e = _error;
          throw new TaskError("Failed to parse task data: " + data);
        }
        eventData = [self, task, data];
        self.emit("perform", eventData);
        task.perform(data, function(error) {
          return self.emit((error ? "success" : "error"), eventData);
        });
      };

      return Worker;

    })(events.EventEmitter);
    return {
      TaskError: TaskError,
      Worker: Worker,
      Queue: Queue
    };
  });

}).call(this);
