
/*!
A simple logging library that improve the original console
with timeline and custom tag support.

@author Wu Yuntao <wyt.brandon@gmail.com>
@license MIT
*/


(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  define("kopi/logging", function(require, exports, module) {
    var ERROR, INFO, LOG, Logger, LoggerError, NOOP_FN, WARN, accumulators, array, console, exceptions, logger, loggers, object, settings, startTime, timers;
    array = require("kopi/utils/array");
    object = require("kopi/utils/object");
    settings = require("kopi/settings");
    exceptions = require("kopi/exceptions");
    LoggerError = (function(_super) {

      __extends(LoggerError, _super);

      function LoggerError() {
        return LoggerError.__super__.constructor.apply(this, arguments);
      }

      return LoggerError;

    })(exceptions.ValueError);
    LOG = 0;
    INFO = 1;
    WARN = 2;
    ERROR = 3;
    NOOP_FN = function() {
      return false;
    };
    NOOP_FN.isNoop = true;
    loggers = {};
    startTime = (window.__KOPI__START_TIME || (window.__KOPI__START_TIME = new Date()));
    timers = {};
    accumulators = {};
    console = null;
    /*
    
      # Logger
    
      A simple logging library that improve the original console
      with timeline and custom tag support.
    
      ## Usage
    
      Just like `console`, a logger has 4 logging levels in a specific order
    
        LOG < INFO < WARN < ERROR
    
      You can update logging level on a logger at runtime.
    
      ## Instantiate a logger instance
    
        logging = require 'logging'
    
        # Get default logger
        logger = logging.logger()
    
        # Or use default logger directly
        logging.log "Say something"
    
        # Get a logger with a custom name
        logger = logging.logger('name_of_logger')
    
        # Get a logger with a custom name and high logging level
        logger = logging.logger 'name_of_logger',
          level: logging.ERROR
    
      Multiple calls to `logging.logger()` with the same name will always
      return a reference to the same `Logger` instance.
    
      ## Logging
    
      `Logger` has a similar interface to `console` object. But only following
      methods are supported: `log`, `info`, `warn`, `error`, `time`, `timeEnd`
    
        # output: [LOG] [0.027s] [kopi] log message [1, 2, 3]
        logger.log "log message", [1, 2, 3]
    
        # output: [INFO] [0.031s] [kopi] info message > Object
        logger.info "info message", key: 'value'
    
        # output: [WARN] [0.031s] [kopi] warn message Help!
        logger.warn "warn message", "Help!"
    
        # output: [ERROR] [0.031s] [kopi] error message > Error
        logger.error "error message", new Error("Something is Wrong")
    
        # output: [LOG] [0.034s] [kopi] time started
        logger.time "prof"
    
        # output [LOG] [1.035s] [kopi] time stoped. spent 1001ms.
        logger.timeEnd "prof"
    
      ## Changing level of logging
    
      `Logger` can change its level of logging by using `logger.level()` method.
    
        # output: 1
        logger.level()
    
        # Increase the logging level
        logger.level logging.WARN
        # output:  false
        logger.info "info message"
    
        # Decrease the logging level
        logger.level logging.LOG
    
        # output: [INFO] [0.031s] [kopi] info message
        logger.info "info message"
    */

    Logger = (function() {
      /*
          Define logging method
      
          @private
          @param {Logger} logger
          @param {String} name
          @return {null}
      */

      var defineMethod, defineNoopMethod;

      defineMethod = function(logger, name) {
        var upper;
        if (logger[name] && !logger[name].isNoop) {
          return;
        }
        upper = name.toUpperCase();
        return logger[name] = function() {
          var seconds;
          seconds = Math.round(new Date() - startTime) / 1000;
          if (console) {
            console[name].apply(console, ["[" + upper + "] [" + seconds + "s] [" + this._name + "]"].concat(__slice.call(arguments)));
          }
        };
      };

      /*
          Define noop method for disallowed logging level
      
          @private
          @param {Logger} logger
          @param {String} name
          @return {null}
      */


      defineNoopMethod = function(logger, name) {
        if (logger[name] && logger[name].isNoop) {
          return;
        }
        return logger[name] = NOOP_FN;
      };

      /*
          Constructor for logger
      
          @constructor
          @param {String} name
          @param {Object} options
      */


      function Logger(name, options) {
        if (options == null) {
          options = {};
        }
        if (!name) {
          throw new LoggerError("Logger must have a name");
        }
        this._level = options.level != null ? options.level : settings.kopi.logging.level;
        this._name = name;
        this.level(this._level);
        loggers[name] = this;
        console || (console = window.console);
      }

      /*
          Return name of logger
      
          @return {String} attribute reader of name
      */


      Logger.prototype.name = function() {
        return this._name;
      };

      /*
          Attribute accessor of logging level
      
          @param {Number} level   If `level` is not provided, returns
                                  current logging level of logger.
                                  If `level` is provided, update current
                                  logger level of logger.
          @return {String|Logger}
      */


      Logger.prototype.level = function(level) {
        var name, value, _i, _len, _ref;
        if (arguments.length === 0) {
          return this._level;
        }
        _ref = ["log", "info", "warn", "error"];
        for (value = _i = 0, _len = _ref.length; _i < _len; value = ++_i) {
          name = _ref[value];
          if (value >= level) {
            defineMethod(this, name);
          } else {
            defineNoopMethod(this, name);
          }
        }
        this._level = level;
        return this;
      };

      /*
          Start a timer under the given name
      
          @param  {String}  name
          @param  {Object}  options
      
          @return {Logger}
      */


      Logger.prototype.time = function(name, options) {
        var key, timer;
        if (options == null) {
          options = {};
        }
        key = "" + this._name + ":" + name;
        timer = timers[key];
        if (timer) {
          return;
        }
        this.log("" + name + " started");
        timers[key] = new Date();
        if (options.accumulate) {
          accumulators[key] || (accumulators[key] = []);
        }
        return this;
      };

      /*
          Stop a timer created by a call to `logger.time(name)`
      
          @param  {String}  name
          @param  {Object}  options
      
          @return {Logger}
      */


      Logger.prototype.timeEnd = function(name, options) {
        var key, message, time, timer;
        if (options == null) {
          options = {};
        }
        key = "" + this._name + ":" + name;
        timer = timers[key];
        if (!timer) {
          return;
        }
        time = new Date() - timer;
        message = "" + name + " stoped. spent " + time + "ms.";
        if (options.accumulate) {
          accumulators[key].push(time);
          message += " total " + (array.sum(accumulators[key])) + "ms. average " + (array.average(accumulators[key])) + "ms.";
        }
        this.log(message);
        timers[key] = null;
        return this;
      };

      return Logger;

    })();
    logger = new Logger("kopi");
    return {
      LOG: LOG,
      INFO: INFO,
      WARN: WARN,
      ERROR: ERROR,
      log: function() {
        return logger.log.apply(logger, arguments);
      },
      info: function() {
        return logger.info.apply(logger, arguments);
      },
      warn: function() {
        return logger.warn.apply(logger, arguments);
      },
      error: function() {
        return logger.error.apply(logger, arguments);
      },
      time: function() {
        return logger.time.apply(logger, arguments);
      },
      timeEnd: function() {
        return logger.timeEnd.apply(logger, arguments);
      },
      /*
        Factory method for loggers
      
        Returns the default logger if `name` is not specified
      
        @param {String} name
        @param {Object} options
      
        @return {Logger}
      */

      logger: function(name, options) {
        var instance;
        instance = name ? loggers[name] || new Logger(name) : logger;
        if (options && (options.level != null)) {
          instance.level(options.level);
        }
        return instance;
      }
    };
  });

}).call(this);
