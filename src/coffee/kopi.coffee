###!

@fileoverview A lightweight CommonJS module manager for Kopi
@author Wu Yuntao <wyt.brandon@gmail.com>
@license MIT

###

# An helper method to check if object is an Array
isArray = (array) -> !!(array and array.concat and array.unshift and not array.callee)

# An helper method to check if object is an Object
isObject = (obj) -> typeof obj is "object"

# A cache object contains all modules with their ids
modules = {}

# Internal module class holding module id, dependencies and exports
class Module

  constructor: (@id, @deps=[], @exports={}) ->
    # Append module to cache
    modules[@id] = this

###
Imports a module.

@param {string} id The module id.

@return {Module}

###
require = (id) ->
  module = modules[id]
  module and module.exports

###
Defines a module.

@param {string} id The module id.
@param {Array} deps The module dependencies.
@param {Function|Object} factory The module factory function.

@return {Module}

###
define = (id, deps, factory) ->
  argsLen = arguments.length

  # define(factory)
  if argsLen == 1
    factory = id
    id = undefined

  # define(id || deps, factory)
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
    exports = factory.call(module, require, module.exports, module)
    module.exports = exports or {}
  else
    module.exports = {}

  module

###!
Exports
###

# Enable AMD for jQuery
define.amd =
  jQuery: true

# Export define() and require() methods
this.define = define
this.require = require
