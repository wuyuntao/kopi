define "kopi/utils/klass", (require, exports, module) ->

  object = require "kopi/utils/object"

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
      this[name] or= property.value
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

  extend: extend
  include: include
  configure: configure
  accessor: accessor
  reader: reader
