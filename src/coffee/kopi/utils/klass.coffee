kopi.module("kopi.utils.klass")
  .require("kopi.utils.object")
  .define (exports, object) ->

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
      klass.configure or= (options) ->
        configure this, options
        this
      extend klass._options, options if options
      object.accessor klass, "options"
      object.accessor klass.prototype, "options"
      klass.prototype.configure = (options) ->
        this._options or= object.clone(this.constructor._options)
        object.extend this._options, options if options
        this
      return

    ###
    Define jQuery-esque property accessor

    @param  {Object}  klass     class owns the accessor
    @param  {String}  method    name of accessor
    @param  {Object}  property  defines default Value, property name, getter and setter.
    ###
    accessor = (klass, method, property={}) ->
      name = property.name or "_#{method}"
      property.get or= ->
        this[name] or= property.value
      property.set or= (value) ->
        this[name] = value
        this
      klass[method] or= ->
        if arguments.length == 0
          property.get.call(this)
        else
          property.set.apply(this, arguments)

    exports.extend = extend
    exports.include = include
    exports.configure = configure
    exports.accessor = accessor
