define "kopi/tests/events", (require, exports, module) ->

  q = require "qunit"
  EventEmitter = require("kopi/events").EventEmitter

  q.module "kopi/events"

  q.test "add listeners", ->
    e = new EventEmitter()
    e.id = 1
    q.stop()
    e.on "new_event", (ev, arg) ->
      q.equal this.id, 1
      q.equal ev.type, "new_event"
      q.equal arg, "arg"
      q.start()
    e.emit "new_event", ["arg"]

  q.test "remove listeners", ->
    e = new EventEmitter()
    listener1 = -> console.log "listener1"
    listener2 = -> console.log "listener2"
    e.on "event1", listener1
    e.off "event1", listener1
    q.equal e.listeners("event1").length, 0

    e.on "event2", listener1
    e.off "event2", listener2
    q.equal e.listeners("event2").length, 1

    e.on "event3", listener1
    e.on "event3", listener2
    e.off "event3", listener1
    q.equal e.listeners("event3").length, 1

  q.test "remove all listeners", ->
    e = new EventEmitter()
    listener1 = -> console.log "listener1"
    listener2 = -> console.log "listener2"
    listener3 = -> console.log "listener3"
    e.on "event1", listener1
    e.on "event2", listener1
    e.on "event2", listener2
    e.on "event3", listener1
    e.on "event3", listener2
    e.on "event3", listener3
    e.off()
    q.equal e.listeners("event1").length, 0
    q.equal e.listeners("event2").length, 0
    q.equal e.listeners("event3").length, 0

  q.test "add one time listeners", ->
    triggered = 0
    e = new EventEmitter()
    listener = -> triggered++
    e.once "once_event", listener
    e.emit "once_event", ["a", "b"]
    e.emit "once_event", ["a", "b"]
    e.emit "once_event", ["a", "b"]
    e.emit "once_event", ["a", "b"]

    e.once 'once_event2', listener
    e.off 'once_event2', listener
    e.emit 'once_event2'

    q.equal triggered, 1
