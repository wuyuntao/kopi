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
      klass._options = object.extend {}, klass._options, options if options
      # Provide hash accessors
      object.accessor klass, "options"
      object.accessor klass.prototype, "options"
      # Provide shortcut functions
      klass.configure or= (options) ->
        configure this, options
        this
      klass.prototype.configure or= (options) ->
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
      return if method of klass
      name = property.name or "_#{method}"
      # Set default getter and setter for property
      property.get or= ->
        this[name] or= property.value
      property.set or= (value) ->
        this[name] = value
        this
      klass.accessor or= (method, property) ->
        accessor this, method, property
        this
      klass[method] or= ->
        if arguments.length == 0
          property.get.call(this)
        else
          property.set.apply(this, arguments)
      return

    exports.extend = extend
    exports.include = include
    exports.configure = configure
    exports.accessor = accessor
