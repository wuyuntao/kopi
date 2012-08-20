###
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

###

## Module definition

# A cache object contains all modules with their ids
modules = {}

# Internal module class holding module id, dependencies and exports
class Module

  constructor: (@id, @deps=[], @exports={}) ->
    # Append module to cache
    modules[@id] = this

###
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

###
define = (id, deps, factory) ->
  argsLen = arguments.length

  # define(factory)
  if argsLen == 1
    factory = id
    id = undefined

  # define(id or deps, factory)
  else if argsLen == 2
    factory = deps
    deps = undefined

    # define(deps, factory)
    if isArray(id)
      deps = id
      id = undefined

  throw new Error("id must be specifed") unless id
  throw new Error("module #{id} is already defined") if id of modules

  module = new Module(id, deps)
  # Initialize exports
  if isObject(factory)
    module.exports = factory

  else if factory
    deps = if deps and deps.length then (require(dep) for dep in deps) else []
    exports = factory.call(module, require, module.exports, module, deps...)
    module.exports = exports if exports

  module

###
## Imports a module.

`require()` function is alse available as a global variable

```coffeescript
require(id)
```

###
require = (id) ->
  module = modules[id]
  throw new Error("module #{id} is not found") if not module
  module.exports

## Helper methods

# An helper method to check if object is an Array
isArray = (array) -> !!(array and array.concat and array.unshift and not array.callee)

# An helper method to check if object is an Object
isObject = (obj) -> typeof obj is "object"

## Exports

# Enable AMD for jQuery
define.amd =
  jQuery: true

# Export define() and require() methods to global namespace
this.define = define
this.require = require
