
/*
Helper methods
*/


(function() {
  var Module, define, isArray, isObject, modules, require;

  isArray = function(array) {
    return !!(array && array.concat && array.unshift && !array.callee);
  };

  isObject = function(obj) {
    return typeof obj === "object";
  };

  /*
  Module class.
  
  @constructor
  @param {String} id The module id.
  @param {Array.<String>|String} deps The module dependencies.
  @param {Function|Object} factory The module factory function.
  */


  Module = (function() {

    function Module(id, deps, factory, exports) {
      this.id = id;
      this.deps = deps != null ? deps : [];
      this.factory = factory;
      this.exports = exports != null ? exports : {};
    }

    return Module;

  })();

  modules = {};

  require = function(id) {
    var module;
    module = modules[id];
    return module && module.exports;
  };

  /*
  Defines a module.
  
  @param {string=} id The module id.
  @param {Array.<string>|string=} deps The module dependencies.
  @param {function()|Object} factory The module factory function.
  */


  define = function(id, deps, factory) {
    var argsLen, exports, module;
    argsLen = arguments.length;
    if (argsLen === 1) {
      factory = id;
      id = void 0;
    } else if (argsLen === 2) {
      factory = deps;
      deps = void 0;
      if (isArray(id)) {
        deps = id;
        id = void 0;
      }
    }
    module = new Module(id, deps, factory);
    if (id in modules) {
      throw new Error("module is double defined!");
    }
    if (id) {
      modules[id] = module;
    }
    if (isObject(factory)) {
      module.exports = factory;
    } else if (factory) {
      exports = factory.call(module, require, module.exports, module);
      if (exports) {
        module.exports = exports;
      }
    }
    return module;
  };

  define.amd = {
    jQuery: true
  };

  this.define = define;

  this.require = require;

}).call(this);
