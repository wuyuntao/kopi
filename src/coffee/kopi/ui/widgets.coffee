define "kopi/ui/widgets", (require, exports, module) ->

  $ = require "jquery"
  utils = require "kopi/utils"
  jquery = require "kopi/utils/jquery"
  klass = require "kopi/utils/klass"
  object = require "kopi/utils/object"
  text = require "kopi/utils/text"
  events = require "kopi/events"
  exceptions = require "kopi/exceptions"
  settings = require "kopi/settings"
  map = require "kopi/utils/structs/map"

  ON = "on"

  ###
  Base class of all UI components

  Life-cycle of a widget

       +--------+
       | Create |
       +---++---+
           ||
           ||
           \/
      +----++----+
      | Skeleton |
      +----++----+
           ||
           ||
           \/
       +---++---+
       | Render |
       +---++---+
           ||         +--------+
           |+-------->+  Lock  |
           ||         +---++---+
           ||             ||
           ||             \/
           ||         +---++---+
           |+<--------+ Unlock |
           ||         +--------+
           ||
           ||         +--------+
           |+<------->+ Update |
           ||         +--------+
           \/
       +---++----+
       | Destroy |
       +---++----+

  1. Create

  2. Skeleton

  3. Render

  4. Destroy

  5. Lock

  6. Unlock

  7. Update

  ###
  class Widget extends events.EventEmitter

    # {{{ Class configuration
    kls = this
    klass.configure kls,
      # @type {String}    tag name of element to create
      tagName: "div"
      # @type {String}    extra css class added to element
      extraClass: ""
      # @type {Template}  Template instance to render element
      template: undefined
      # @type {Hash}      Context can be used when rendering template
      context: undefined
    # }}}

    # {{{ Events
    kls.SKELETON_EVENT = "skeleton"
    kls.RENDER_EVENT = "render"
    kls.UPDATE_EVENT = "update"
    kls.DESTROY_EVENT = "destroy"
    kls.LOCK_EVENT = "lock"
    kls.UNLOCK_EVENT = "unlock"
    kls.RESIZE_EVENT = "resize"
    # }}}

    # {{{ Accessors
    klass.accessor kls, "widgetName",
      get: -> this._widgetName or= this.name

    proto = kls.prototype
    klass.accessor proto, "end"
    # }}}

    # {{{ Class methods
    ###
    A helper method to generate CSS class names added to widget element
    ###
    kls.cssClass = (action, prefix="") ->
      this._cssClasses or= {}
      key = "#{action},#{prefix}"
      value = this._cssClasses[key]
      if not value
        this.prefix or= text.dasherize(this.widgetName(), '-')
        value = this.prefix
        value = prefix + "-" + value if prefix
        value = (this._options.prefix or settings.kopi.ui.prefix) + "-" + value
        value = value + "-" + action if action
        this._cssClasses[key] = value
      value

    kls.eventName = (name) ->
      this._eventNames or= {}
      value = this._eventNames[name]
      if not value
        this.namespace or= "." + this.widgetName().toLowerCase()
        value = name + this.namespace
        this._eventNames[name] = value
      value

    ###
    A helper method to generate CSS class names regexps for states
    ###
    kls.stateRegExp = (prefix="") ->
      this._stateRegExps or= {}
      return this._stateRegExps[prefix] if prefix of this._stateRegExps

      regExp = new RegExp(this.cssClass("[^\s]+\s*", prefix), 'g')
      this._stateRegExps[prefix] = regExp
    # }}}

    # {{{ Lifecycle methods
    constructor: (options={}) ->
      self = this
      # @type {String}
      self.constructor.prefix or= text.dasherize(self.constructor.widgetName())
      # @type {String}
      self.guid = utils.guid(self.constructor.prefix)
      # @type {Object}
      self._end = null

      # {{{ State properties
      # If skeleton has been built
      self.initialized = false
      # If widget is rendered with data
      self.rendered = false
      # If widget is disabled
      self.locked = false
      # If widget is active
      self.active = true
      # }}}

      # Copy class configurations to instance
      self.configure(options)

    ###
    Ensure basic skeleton of widget usually with a loader
    ###
    skeleton: (element) ->
      cls = this.constructor
      self = this
      return self if self.initialized or self.locked
      self.element or= self._ensureElement(element)
      self.element.attr('id', self.guid)
      cssClass = cls.cssClass()
      if not self.element.hasClass(cssClass)
        self.element.addClass(cssClass)
      self._readOptions()
      if self._options.extraClass
        self.element.addClass(self._options.extraClass)
      self.emit(cls.SKELETON_EVENT)
      if self._widgets
        self._widgets.forEach (name, widget) ->
          widget.skeletonTo(self.element) if widget.options().autoSkeleton isnt false
      self.initialized = true
      self

    skeletonTo: (element) ->
      cls = this.constructor
      this.skeleton().appendTo(element)

    ###
    Render widget when data is ready
    ###
    render: ->
      self = this
      return self if self.rendered or self.locked
      cls = this.constructor
      self.emit cls.RENDER_EVENT
      # Emit resize event for first time
      self.emit cls.RESIZE_EVENT
      if self._widgets
        self._widgets.forEach (name, widget) ->
          widget.render() if widget.options().autoRender isnt false
      self.rendered = true
      self

    update: ->
      self = this
      return self if self.locked
      cls = this.constructor
      self.emit(cls.UPDATE_EVENT)

    ###
    Unregister event listeners, remove elements and so on
    ###
    destroy: ->
      self = this
      return self if self.locked or (not self.initialized and not self.rendered)
      cls = this.constructor
      self.element.remove()
      self.off()
      self.emit(cls.DESTROY_EVENT)
      if self._widgets
        self._widgets.forEach (name, widget) ->
          widget.destroy() if widget.options().autoDestroy isnt false
      self.initialized = false
      self.rendered = false
      self

    ###
    Disable events
    ###
    lock: ->
      self = this
      return self if self.locked
      cls = this.constructor
      # TODO Disable events too?
      self.element.addClass(self.constructor.cssClass("lock"))
      self.emit(cls.LOCK_EVENT)
      self.locked = true
      self

    ###
    Enable events
    ###
    unlock: ->
      self = this
      return self unless self.locked
      cls = this.constructor
      self.element.removeClass(self.constructor.cssClass("lock"))
      self.emit(cls.UNLOCK_EVENT)
      self.locked = false
      self
    # }}}

    # {{{ Event template methods
    onskeleton: ->
    onrender: ->
    onupdate: ->
    ondestroy: ->
    onresize: ->
    onlock: ->
    onunlock: ->
    # }}}

    # {{{ Helper methods
    defineMethod = (proto, method) ->
      proto[method] = ->
        this.element[method](arguments...)
        this
    for method in ["appendTo", "prependTo"]
      defineMethod(proto, method)
    ###
    Check if widgets are same
    ###
    equals: (widget) ->
      this.guid == widget.guid

    ###
    Human readable widget name
    ###
    widget: ->
      this.element

    toString: ->
      "[#{this.constructor.widgetName()} #{this.guid}]"

    ###
    Add or update state class and data attribute to element
    ###
    state: (name, value) ->
      if value == null
        this.element.attr("data-#{name}")
      else
        cls = this.constructor
        this.element
          .attr("data-#{name}", value)
          .replaceClass(cls.stateRegExp(name), "")
          .addClass(cls.cssClass(value, name))

    ###
    Remove state class and data attribute from element
    ###
    removeState: (name) ->
      this.element
        .removeAttr("data-#{name}")
        .replaceClass(this.constructor.stateRegExp(name), "")

    ###
    Create a child widget which is initialized, rendered and destroyed
    when parent widget is doing so

    ###
    register: (name, widgetClass, options) ->
      self = this
      self._widgets or= new map.Map()
      # Create widget instance
      widgetOptions = self._extractOptions(name)
      object.extend(widgetOptions, options) if options
      widget = new widgetClass(widgetOptions).end(self)
      # Create accessor for widget
      self["_" + name] = widget
      klass.accessor self, name
      # Add child widget stack
      self._widgets.set(name, widget)
      # TODO Auto emit resize event for child widgets when parent widget size changes?
      # if options.resize
      #   self.on cls.RESIZE_EVENT, -> widget.emit cls.RESIZE_EVENT
      self

    ###
    Remove a child widget with the given name

    ###
    unregister: (name) ->
      self = this
      return if not self._widgets
      widget = self._widgets.get(name)
      if name and widget
        # Remove child widget from stack
        self._widgets.remove(name)
        # Remove accessor
        delete self[name]
        delete self["_" + name]
        # Destroy widget
        widget.destroy()
      self

    # }}}

    # {{{ Private methods
    ###
    Get or create element
    ###
    _ensureElement: (element) ->
      self = this
      return $(element) if element
      if self._options.element
        element = $(self._options.element)
        return element if element.length
      element = $(document.createElement(self._options.tagName))
      if self._options.template
        element.html(self._options.template.render(self._options.context))
      element

    ###
    Get or create wrapper element
    ###
    _ensureWrapper: (name="wrapper", tag="div", parent) ->
      cls = this.constructor
      self = this
      parent or= self.element
      cssClass = cls.cssClass(name)
      wrapper = $("." + cssClass, parent)
      if not wrapper.length
        wrapper = $("<#{tag}></#{tag}>", class: cssClass).appendTo(parent)
      wrapper

    ###
    Update options from data attributes of element
    ###
    _readOptions: ->
      return this unless this.element.length > 0
      for name, value of this._options
        value = this.element.data(text.dasherize(name))
        this._options[name] = value if value isnt undefined
      this

    ###
    DEPRECATED execute callback function defined in options
    ###
    _callback: (event, args) ->
      fn = this._options[ON + event]
      fn.apply(this, args) if fn
      this

    ###
    Extract options with specfic prefix
    ###
    _extractOptions: (prefix) ->
      return self._options if not prefix

      self = this
      options = {}
      for name, value of self._options
        if text.startsWith(name, prefix)
          name = text.lowercase(name.replace(prefix, ""))
          options[name] = value
      options

    # }}}

  Widget: Widget
