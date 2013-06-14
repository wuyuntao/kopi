(function() {
  define("kopi/tests/events", function(require, exports, module) {
    var EventEmitter, q;

    q = require("qunit");
    EventEmitter = require("kopi/events").EventEmitter;
    q.module("kopi/events");
    q.test("add listeners", function() {
      var e;

      e = new EventEmitter();
      e.id = 1;
      q.stop();
      e.on("new_event", function(ev, arg) {
        q.equal(this.id, 1);
        q.equal(ev.type, "new_event");
        q.equal(arg, "arg");
        return q.start();
      });
      return e.emit("new_event", ["arg"]);
    });
    q.test("remove listeners", function() {
      var e, listener1, listener2;

      e = new EventEmitter();
      listener1 = function() {
        return console.log("listener1");
      };
      listener2 = function() {
        return console.log("listener2");
      };
      e.on("event1", listener1);
      e.off("event1", listener1);
      q.equal(e.listeners("event1").length, 0);
      e.on("event2", listener1);
      e.off("event2", listener2);
      q.equal(e.listeners("event2").length, 1);
      e.on("event3", listener1);
      e.on("event3", listener2);
      e.off("event3", listener1);
      return q.equal(e.listeners("event3").length, 1);
    });
    q.test("remove all listeners", function() {
      var e, listener1, listener2, listener3;

      e = new EventEmitter();
      listener1 = function() {
        return console.log("listener1");
      };
      listener2 = function() {
        return console.log("listener2");
      };
      listener3 = function() {
        return console.log("listener3");
      };
      e.on("event1", listener1);
      e.on("event2", listener1);
      e.on("event2", listener2);
      e.on("event3", listener1);
      e.on("event3", listener2);
      e.on("event3", listener3);
      e.off();
      q.equal(e.listeners("event1").length, 0);
      q.equal(e.listeners("event2").length, 0);
      return q.equal(e.listeners("event3").length, 0);
    });
    return q.test("add one time listeners", function() {
      var e, listener, triggered;

      triggered = 0;
      e = new EventEmitter();
      listener = function() {
        return triggered++;
      };
      e.once("once_event", listener);
      e.emit("once_event", ["a", "b"]);
      e.emit("once_event", ["a", "b"]);
      e.emit("once_event", ["a", "b"]);
      e.emit("once_event", ["a", "b"]);
      e.once('once_event2', listener);
      e.off('once_event2', listener);
      e.emit('once_event2');
      return q.equal(triggered, 1);
    });
  });

}).call(this);
