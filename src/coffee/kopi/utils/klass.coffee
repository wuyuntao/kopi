kopi.module("kopi.utils.klass")
  .require("kopi.exceptions")
  .require("kopi.utils")
  .define (exports, exceptions, utils) ->

    extend = (klass, mixin) ->
      for name, method of mixin
        klass[name] = method
      return

    include = (klass, mixin) ->
      for name, method of mixin.prototype
        klass.prototype[name] = method
      return

    configure = (klass, options) ->
      klass._options or= {}
      utils.extend klass._options, options
      accessor klass, "options"
      accessor klass.prototype, "options"
      return

    accessor = (klass, method, property) ->
      property = "_#{method}"
      klass[method] = (name, value) ->
        obj = this[property] or= {}
        switch arguments.length
          when 0 then return obj
          when 1 then return obj[name]
          else return obj[name] = value
      return

    exports.extend = extend
    exports.include = include
    exports.configure = configure
    exports.accessor = accessor
