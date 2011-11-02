kopi.module("kopi.utils.klass")
  .require("kopi.exceptions")
  .require("kopi.utils")
  .define (exports, exceptions, utils) ->

    extend = (klass, mixin) ->
      for name, method of mixin
        klass[name] = method
      klass

    include = (klass, mixin) ->
      for name, method of mixin.prototype
        klass.prototype[name] = method
      klass

    configure = (klass, options) ->
      klass._options or= {}
      utils.extend klass._options, options

      klass.prototype._options or= {}
      klass.prototype.options = (name, value) ->
        accessor(this._options, name, value)

    accessor = (klass, methodName, variableName) ->
      variableName or= "_#{methodName}"
      klass.prototype[methodName] = (name, value) ->
        obj = this[variableName]
        switch arguments.length
          when 0 then return obj
          when 1 then return obj[name]
          else return obj[name] = value

    exports.extend = extend
    exports.include = include
    exports.configure = configure
    exports.accessor = accessor
