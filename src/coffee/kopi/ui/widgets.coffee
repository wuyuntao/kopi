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

      # @type {Hash}    默认配置
      this._defaults = {
        # @type {String}    tag name of element to create
        tagName: "div"

        # @type {Boolean}   Build skeleton if element does not exist
        autoCreate: false
      }

      ###
      更新默认配置
      ###
      this.defaults = (options={}) ->
        $.extend(this._defaults, options)

      ###
      CSS class name should be added to widget element
      ###
      this.cssClass = (action, prefix=null) ->
        this.prefix or= text.underscore(this.name)
        name = this.prefix
        name = prefix + "-" + name if prefix
        name = settings.kopi.ui.prefix + "-" + name if settings.kopi.ui.prefix
        name = name + "-" + action if action
        name

      constructor: (element, options={}) ->
        self = this
        # @type {String}
        self.constructor.prefix or= text.underscore(self.constructor.name)

        # @type {String}
        self.uid = utils.uniqueId(self.constructor.prefix)

        # @type {Hash}              配置
        self._options = $.extend({}, self.constructor._defaults, options)

        # @type {jQuery Element}
        self.element = $(element)
        if self.element.length == 0 and not self._options.autoCreate
          throw new exceptions.ValueError("Element does not exist: #{element}")
        self._updateOptions()
        self._skeleton()

        # @type {Hash}              数据
        self._data = {}

        # @type {Boolean}           是否允许用户交互
        self.isLocked = false

      ###
      更新配置
      ###
      options: (options) ->
        if options then $.extend(this._options, options) else this._options

      ###
      禁止用户用鼠标或手势进行交互
      ###
      lock: ->
        self = this
        return self if self.locked
        # TODO 从 Event 层禁止，考虑如果子类也在 element 上绑定时间的情况
        self.isLocked = true
        self.element.addClass(self.constructor.cssClass("lock"))
        self.onlock()
        self

      ###
      禁止用户用鼠标、键盘或手势进行交互
      ###
      unlock: ->
        self = this
        return self unless self.locked
        self.isLocked = false
        self.element.removeClass(self.constructor.cssClass("lock"))
        self.onunlock()
        self

      ###
      Ensure elements are created and properly configured
      ###
      _skeleton: ->
        self = this

        unless self.element.length
          self.element = $(document.createElement(self._options.tagName))

        if not self.element.data('uid')
          self.element.attr('data-uid', self.uid)

        cssClass = self.constructor.cssClass()
        if not self.element.hasClass(cssClass)
          self.element.addClass(cssClass)

      ###
      从 HTML Element 的 data 属性上读取配置

      @param  {HTML Element}  element
      ###
      _updateOptions: ->
        return unless this.element.length > 0

        for name, value of this._options
          value = this.element.data(text.underscore(name))
          this._options[name] = value if value isnt undefined

      onlock:    -> true
      onunlock:  -> true

    ###
    可响应视区事件的 Widget
    ###
    class ResizableWidget extends Widget

    exports.Widget = Widget
    exports.ResizableWidget = ResizableWidget
