define "kopi/utils/klass", (require, exports, module) ->

  object = require "kopi/utils/object"
  {SingletonError} = require "kopi/exceptions"

  ###
  Define CoffeeScript style class which could be useful for
  guys who uses Kopi with JavaScript.

  @param {String} name Class name
  @param {Object} parent Constructor function to inherit prototype from
  ###
  create = (name, parent) ->
    if parent
      klass = ->
        parent.constructor.apply(this, arguments)
      klass.__super__ = parent.prototype
      if parent
        # Assign class properties
        for own key, value of parent
          klass[key] = value
    else
      klass = ->
    # constructor.name is a read-only property in webkit and some other browsers
    klass.name = klass.__name__ = name
    ctor = -> this.constructor = klass
    # Assign instance properties
    ctor.prototype = parent.prototype if parent
    klass.prototype = new ctor()
    klass

  ###
  Include a mixin object for class
  ###
  include = (klass, mixin) ->
    # extend class properties
    for own name, method of mixin
      klass[name] = method
    # extend instance properties
    for own name, method of mixin.prototype
      klass.prototype[name] = method
    klass

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
    klass.prototype.configure or= () ->
      this._options or= object.clone(this.constructor._options)
      object.extend this._options, arguments... if arguments.length
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
      if this[name]? then this[name] else property.value
    property.set or= (value) ->
      this[name] = value
    klass.accessor or= (method, property) ->
      accessor this, method, property
      this
    klass[method] or= ->
      if arguments.length == 0
        property.get.call(this)
      else
        property.set.apply(this, arguments)
        this
    return

  ###
  Define jQuery-esque property read-only accessor

  @param  {Object}  klass     class owns the accessor
  @param  {String}  method    name of accessor
  @param  {Object}  property  defines default Value, property name, getter and setter.
  ###
  reader = (klass, method, property={}) ->
    return if method of klass
    name = property.name or "_#{method}"
    # Set default getter and setter for property
    property.get or= ->
      this[name] or= property.value
    klass.reader or= (method, property) ->
      reader this, method, property
      this
    klass[method] or= ->
      property.get.apply(this, arguments)
    return

  ###
  Provide singleton interface for class

  @param  {Object}  klass     singleton class
  ###
  singleton = (klass) ->
    instance = null
    klass.instance = -> instance
    klass.prototype._isSingleton = ->
      throw new SingletonError(klass) if instance
      instance = this

  create: create
  include: include
  configure: configure
  accessor: accessor
  reader: reader
  singleton: singleton
