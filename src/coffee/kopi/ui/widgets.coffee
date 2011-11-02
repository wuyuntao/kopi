kopi.module("kopi.ui.widgets")
  .require("kopi.utils")
  .require("kopi.utils.text")
  .require("kopi.events")
  .require("kopi.exceptions")
  .require("kopi.settings")
  .define (exports, utils, text, events, exceptions, settings) ->

    ###
    UI 组件的基类
    ###
    class Widget extends events.EventEmitter

      # {{{ Class configuration
      utils.configure this
        # @type {String}    tag name of element to create
        tagName: "div"
      # }}}

      # {{{ Class methods
      ###
      A helper method to generate CSS class names added to widget element
      ###
      this.cssClass = (action, prefix="") ->
        this._cssClasses or= {}
        cache = "#{action},#{prefix}"
        return this._cssClasses[cache] if cache of this._cssClasses

        this.prefix or= text.underscore(this.name)
        name = this.prefix
        name = prefix + "-" + name if prefix
        name = settings.kopi.ui.prefix + "-" + name if settings.kopi.ui.prefix
        name = name + "-" + action if action
        this._cssClasses[cache] = name

      ###
      A helper method to generate CSS class names regexps for states
      ###
      this.stateRegExp = (prefix="") ->
        this._stateRegExps or= {}
        return this._stateRegExps[prefix] if prefix of this._stateRegExps

        regExp = new RegExp(this.cssClass("[^\s]+\s*", prefix), 'g')
        this._stateRegExps[prefix] = regExp
      # }}}

      # {{{ State properties
      # If skeleton has been built
      initialized: false

      # If widget is rendered with data
      rendered: false

      # If widget is disabled
      locked: false
      # }}}

      # {{{ Lifecycle methods
      constructor: (element, options={}, data={}) ->
        self = this
        # @type {String}
        self.constructor.prefix or= text.underscore(self.constructor.name)
        # @type {String}
        self.uid = utils.uniqueId(self.constructor.prefix)
        # @type {jQuery Element}
        self.element = element if element
        # @type {Hash}              数据
        self.data = data
        # Copy class configurations to instance
        utils.configure self, self.constructor.options, options

      ###
      Ensure basic skeleton of widget usually with a loader
      ###
      skeleton: (element, data) ->
        self = this
        return self if self.initialized or self.locked
        self.element = self._getElement(element or self.element)
        self.element.attr('id', self.uid)
        cssClass = self.constructor.cssClass()
        if not self.element.hasClass(cssClass)
          self.element.addClass(cssClass)
        utils.extend self.data, data or {}
        self.configure()
        self.emit("initialize")

      ###
      Render widget when data is ready
      ###
      render: (data) ->
        self = this
        return self if self.rendered or self.locked
        utils.extend self.data, data or {}
        self.emit("render")

      update: (data) ->
        self = this
        return self if self.locked
        utils.extend self.data, data or {}
        self.emit("update")

      ###
      Disable events
      ###
      lock: ->
        self = this
        return self if self.locked
        # TODO 从 Event 层禁止，考虑如果子类也在 element 上绑定时间的情况
        self.locked = true
        self.element.addClass(self.constructor.cssClass("lock"))
        self.emit('lock')

      ###
      Enable events
      ###
      unlock: ->
        self = this
        return self unless self.locked
        self.locked = false
        self.element.removeClass(self.constructor.cssClass("lock"))
        self.emit('unlock')

      ###
      Unregister event listeners, remove elements and so on
      ###
      destroy: ->
        self = this
        return self if self.locked
        self.element.remove()
        self.off()
        self.emit('destroy')
      # }}}

      # {{{ Event template methods
      # }}}

      # {{{ Helper methods
      ###
      Update options from data attributes of element
      ###
      configure: (options={}) ->
        return unless this.element.length > 0
        for name, value of this.options
          value = this.element.data(text.underscore(name))
          this.options[name] = value if value isnt undefined

      toString: ->
        "[#{this.constructor.name} #{this.uid}]"

      ###
      Add or update state class and data attribute to element
      ###
      state: (name, value) ->
        if value == null
          this.element.attr("data-#{name}")
        else
          this.element
            .attr("data-#{name}", value)
            .replaceClass(this.constructor.stateRegExp(name),
              this.constructor.cssClass(value, name))

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
      _getElement: (element) ->
        self = this
        return $(element) if element
        if self.options.element
          return $(self.options.element)
        if self.options.template
          return $(self.options.template).tmpl(self.data)
        $(document.createElement(self.options.tagName))
      # }}}

    exports.Widget = Widget
