kopi.module("kopi.ui.widgets")
  .require("kopi.utils")
  .require("kopi.utils.jquery")
  .require("kopi.utils.klass")
  .require("kopi.utils.object")
  .require("kopi.utils.text")
  .require("kopi.events")
  .require("kopi.exceptions")
  .require("kopi.settings")
  .define (exports, utils, jquery, klass, object, text, events, exceptions, settings) ->

    ON = "on"

    ###
    UI 组件的基类

    Life-cycle of a widget

                      +--------+
                      | Create |
                      +---++---+
                          ||
          +-------------->+|
          |               ||
          |               \/
          |          +----++----+
          |          | Skeleton |
     +----+----+     +----++----+
     | Recycle |          ||
     +----+----+          \/
          ^          +----++----+
          |          | Delegate |
          |          +----++----+
          |               ||
          |               \/
          |           +---++---+
          |           | Render |
          |           +---++---+
          |               ||         +--------+
          |               |+-------->+  Lock  |
    +-----+------+        ||         +---++---+
    | Inactivate +<-------+|             ||
    +-----+------+        ||             \/
          |               ||         +---++---+
          |               |+<--------+ Unlock |
          |               ||         +--------+
          V               ||
     +----+-----+         ||         +--------+
     | Activate +-------->++<------->+ Update |
     +----------+         ||         +--------+
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

    7. Activate

    8. Inactivate

    9. Recycle

    ###
    class Widget extends events.EventEmitter

      # {{{ Class configuration
      klass.configure this,
        # @type {String}    tag name of element to create
        tagName: "div"
        # @type {String}    extra css class added to element
        extraClass: ""

      # }}}

      # {{{ Accessors
      proto = this.prototype
      klass.accessor proto, "end"
      # }}}

      # {{{ Class methods
      ###
      A helper method to generate CSS class names added to widget element
      ###
      this.cssClass = (action, prefix="") ->
        this._cssClasses or= {}
        key = "#{action},#{prefix}"
        value = this._cssClasses[key]
        if not value
          this.prefix or= text.underscore(this.name)
          value = this.prefix
          value = value + "-" + prefix if prefix
          value = settings.kopi.ui.prefix + "-" + value if settings.kopi.ui.prefix
          value = value + "-" + action if action
          this._cssClasses[key] = value
        value

      this.eventName = (name) ->
        this._eventNames or= {}
        value = this._eventNames[name]
        if not value
          this.namespace or= "." + this.name.toLowerCase()
          value = name + this.namespace
          this._eventNames[name] = value
        value

      ###
      A helper method to generate CSS class names regexps for states
      ###
      this.stateRegExp = (prefix="") ->
        this._stateRegExps or= {}
        return this._stateRegExps[prefix] if prefix of this._stateRegExps

        regExp = new RegExp(this.cssClass("[^\s]+\s*", prefix), 'g')
        this._stateRegExps[prefix] = regExp
      # }}}

      # {{{ Lifecycle methods
      constructor: (element, options={}) ->
        if arguments.length < 2
          [element, options] = [null, element]

        self = this
        # @type {String}
        self.constructor.prefix or= text.underscore(self.constructor.name)
        # @type {String}
        self.guid = utils.guid(self.constructor.prefix)
        # @type {jQuery Element}
        self.element = element if element
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
        self = this
        return self if self.initialized or self.locked
        self.element = self._ensureElement(element or self.element)
        self.element.attr('id', self.guid)
        cssClass = self.constructor.cssClass()
        if not self.element.hasClass(cssClass)
          self.element.addClass(cssClass)
        self._readOptions()
        if self._options.extraClass
          self.element.addClass(self._options.extraClass)
        self.emit("skeleton")

      delegate: ->
        this.emit("delegate")

      resize: ->
        this.emit("resize")

      ###
      Render widget when data is ready
      ###
      render: () ->
        self = this
        return self if self.rendered or self.locked
        self.emit("render")

      update: () ->
        self = this
        return self if self.locked
        self.emit("update")

      ###
      Unregister event listeners, remove elements and so on
      ###
      destroy: ->
        self = this
        return self if self.locked
        self.element.remove()
        self.off()
        self.emit('destroy')

      ###
      Disable events
      ###
      lock: ->
        self = this
        return self if self.locked
        # TODO 从 Event 层禁止，考虑如果子类也在 element 上绑定时间的情况
        self.element.addClass(self.constructor.cssClass("lock"))
        self.emit('lock')

      ###
      Enable events
      ###
      unlock: ->
        self = this
        return self unless self.locked
        self.element.removeClass(self.constructor.cssClass("lock"))
        self.emit('unlock')

      inactivate: ->
        this.emit("inactivate")

      activate: ->
        this.emit("activate")
      # }}}

      # {{{ Event template methods
      onskeleton: ->
        this.delegate()
        this.initialized = true

      ondelegate: ->

      onrender: ->
        this.resize()
        this.rendered = true

      onupdate: ->

      ondestroy: ->
        this.initialized = false
        this.rendered = false

      onsizechange: ->

      onlock: ->
        this.locked = true

      onunlock: ->
        this.locked = false

      onactivate: ->
        this.active = true

      oninactivate: ->
        this.active = false

      onrecycle: ->
        this.initialized = false
        this.rendered = false

      # }}}

      # {{{ Helper methods
      ###
      Human readable widget name
      ###
      widget: ->
        this.element

      toString: ->
        "[#{this.constructor.name} #{this.guid}]"

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
      # }}}

      # {{{ Private methods
      ###
      Get or create element
      ###
      _ensureElement: (element) ->
        self = this
        return $(element) if element
        if self._options.element
          return $(self._options.element)
        if self._options.template
          return $(self._options.template).tmpl(self)
        $(document.createElement(self._options.tagName))

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
          value = this.element.data(text.underscore(name))
          this._options[name] = value if value isnt undefined
        this

      ###
      execute callback function defined in options
      ###
      _callback: (event, args) ->
        fn = this._options[ON + event]
        fn(args...) if fn
        this

      # }}}

    exports.Widget = Widget
