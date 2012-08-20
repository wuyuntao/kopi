
/*
# Module Manager

A lightweight [AMD](https://github.com/amdjs/amdjs-api/wiki/AMD) manager.

It provides the minimal AMD API without any dynamic code loading.

## Why

Kopi uses AMD API to write modular JavaScript. So it works perfectly
with full-featured AMD loaders, like [RequireJS](http://requirejs.org)
or [curl.js](https://github.com/unscriptable/curl).

However, in some cases which are sensitive to file sizes and requests,
we prefer to combine and minify all JavaScript files into one file.

By including A minimal AMD manager, A full-featured AMD loader is not
necessary. And it is only *475 bytes* after minified and gzipped.

## Limitations

Since module manager is optimized for single-file javascript, there are
two limitations of module id format.

1. Anomynous module is not supported.
2. Relative ids are not supported either in `define()` or `require()`.
3. Module ids should not include file-name extesions like ".js".
*/


(function() {
  var Module, define, isArray, isObject, modules, require,
    __slice = [].slice;

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
  ## Define a module.
  
  `define()` function is available as a global variable.
  
  ```coffeescript
  define(id, dep?, factory?)
  ```
  
  Either AMD-style or CommonJS-style dependencies are supported.
  
  ```coffeescript
  define "alpha", ["beta"], (require, exports, module, beta) ->
  
    gamma = require "gamma"
  
    exports.hello = ->
      beta.hello()
      gamma.hello()
  
  ```
  
  An module can return an object as its exports
  
  ```coffeescript
  define "alpha", (require, exports, module) ->
  
    say: -> console.log "say"
    hello: -> console.log "hello"
  
  ```
  
  Or define module with an object directly
  
  ```coffeescript
  define "alpha",
    say: -> console.log "say"
    hello: -> console.log "hello"
  
  ``
  */


  define = function(id, deps, factory) {
    var argsLen, dep, exports, module;
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
      deps = deps && deps.length ? (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = deps.length; _i < _len; _i++) {
          dep = deps[_i];
          _results.push(require(dep));
        }
        return _results;
      })() : [];
      exports = factory.call.apply(factory, [module, require, module.exports, module].concat(__slice.call(deps)));
      if (exports) {
        module.exports = exports;
      }
    }
    return module;
  };

  /*
  ## Imports a module.
  
  `require()` function is alse available as a global variable
  
  ```coffeescript
  require(id)
  ```
  */


  require = function(id) {
    var module;
    module = modules[id];
    if (!module) {
      throw new Error("module " + id + " is not found");
    }
    return module.exports;
  };

  isArray = function(array) {
    return !!(array && array.concat && array.unshift && !array.callee);
  };

  isObject = function(obj) {
    return typeof obj === "object";
  };

  define.amd = {
    jQuery: true
  };

  this.define = define;

  this.require = require;

}).call(this);
