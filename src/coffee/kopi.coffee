###
Helper methods
###
isArray = (array) -> !!(array and array.concat and array.unshift and not array.callee)

isObject = (obj) -> typeof obj is "object"

###
Module class.

@constructor
@param {String} id The module id.
@param {Array.<String>|String} deps The module dependencies.
@param {Function|Object} factory The module factory function.
###
class Module

  constructor: (@id, @deps=[], @factory, @exports={}) ->

# @type  {Object} Cache contains all modules
modules = {}

require = (id) ->
  module = modules[id]
  module and module.exports

###
Defines a module.

@param {string=} id The module id.
@param {Array.<string>|string=} deps The module dependencies.
@param {function()|Object} factory The module factory function.
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

  module = new Module(id, deps, factory)
  if id of modules
    throw new Error("module is double defined!")

  modules[id] = module if id
  if isObject(factory)
    module.exports = factory
  else if factory
    exports = factory.call(module, require, module.exports, module)
    module.exports = exports if exports

  module

define.amd =
  jQuery: true

# Export define method
this.define = define
this.require = require
