(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  define("kopi/logging", function(require, exports, module) {
    var ERROR, INFO, LOG, Logger, LoggerError, NOOP_FN, WARN, array, exceptions, logger, loggers, object, settings;
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
    NOOP_FN = function() {};
    NOOP_FN.isNoop = true;
    loggers = {};
    /*
      Improve original console with tag, time and extra handlers
    
      # TODO Implement logging handler mechanism like Python
    */

    Logger = (function() {
      var accumulators, console, defineMethod, defineNoopMethod, start, timers;

      start = (window.__KOPI__START_TIME || (window.__KOPI__START_TIME = new Date()));

      timers = {};

      accumulators = {};

      console = null;

      /*
          Define logging method
      
          @private
      */


      defineMethod = function(logger, name) {
        if (logger[name] && !logger[name].isNoop) {
          return;
        }
        return logger[name] = function() {
          var seconds;
          seconds = Math.round(new Date() - start) / 1000;
          if (console) {
            console[name].apply(console, ["[" + seconds + "s] [" + this._name + "]"].concat(__slice.call(arguments)));
          }
        };
      };

      /*
          Define noop method for disallowed logging level
      
          @private
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
      */


      function Logger(name, options) {
        if (options == null) {
          options = {};
        }
        if (!name) {
          throw new LoggerError("Logger must have a name");
        }
        this._level = settings.kopi.logging.level;
        this._name = name;
        this.level(this._level);
        loggers[name] = this;
        console || (console = window.console);
      }

      /*
          Return name of logger
      */


      Logger.prototype.name = function() {
        return this._name;
      };

      /*
          Accessor of logging level
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
          @param  {Hash}    options
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
          Stop a timer created by a call to Logger.time(name)
      
          @param  {String}  name
          @param  {Hash}    options
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
      */

      logger: function(name) {
        if (name) {
          return loggers[name] || new Logger(name);
        } else {
          return logger;
        }
      }
    };
  });

}).call(this);
