(function() {

  define("kopi/tests/logging", function(require, exports, module) {
    var logging, q;
    q = require("qunit");
    logging = require("kopi/logging");
    q.module("kopi.logging");
    q.test("default logger", function() {
      logging.log("log message");
      logging.info("info message");
      logging.warn("warn message");
      logging.error("error message");
      return q.ok(true);
    });
    q.test("time metrics", function() {
      q.stop();
      logging.time("time");
      return setTimeout((function() {
        logging.timeEnd("time");
        q.ok(true);
        return q.start();
      }), 1000);
    });
    return q.test("setup logging level", function() {
      var logger;
      logger = logging.logger("custom_logger");
      logger.level(logging.WARN);
      logger.log("log message");
      logger.info("info message");
      logger.warn("warn message");
      logger.error("error message");
      return q.ok(true);
    });
  });

}).call(this);
