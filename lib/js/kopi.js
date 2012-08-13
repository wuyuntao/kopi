
/*!

@fileoverview A lightweight CommonJS module manager for Kopi
@author Wu Yuntao <wyt.brandon@gmail.com>
@license MIT
*/


(function() {
  var Module, define, isArray, isObject, modules, require;

  isArray = function(array) {
    return !!(array && array.concat && array.unshift && !array.callee);
  };

  isObject = function(obj) {
    return typeof obj === "object";
  };

  modules = {};

  Module = (function() {

    function Module(id, deps, exports) {
      this.id = id;
      this.deps = deps != null ? deps : [];
      this.exports = exports != null ? exports : {};
      modules[this.id] = this;
    }

    return Module;

  })();

  /*
  Imports a module.
  
  @param {string} id The module id.
  
  @return {Module}
  */


  require = function(id) {
    var module;
    module = modules[id];
    return module && module.exports;
  };

  /*
  Defines a module.
  
  @param {string} id The module id.
  @param {Array} deps The module dependencies.
  @param {Function|Object} factory The module factory function.
  
  @return {Module}
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
    if (!id) {
      throw new Error("id must be specifed");
    }
    if (id in modules) {
      throw new Error("module " + id + " is already defined");
    }
    module = new Module(id, deps);
    if (isObject(factory)) {
      module.exports = factory;
    } else if (factory) {
      exports = factory.call(module, require, module.exports, module);
      module.exports = exports || {};
    } else {
      module.exports = {};
    }
    return module;
  };

  /*!
  Exports
  */


  define.amd = {
    jQuery: true
  };

  this.define = define;

  this.require = require;

}).call(this);
