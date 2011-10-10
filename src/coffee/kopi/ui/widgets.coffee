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
      this._defaults = {}

      ###
      更新默认配置
      ###
      this.defaults = (options={}) ->
        $.extend(this._defaults, options)

      constructor: (element, options={}, data={}) ->
        self = this
        # @type {String}
        self.constructor.prefix or= text.underscore(self.constructor.name)
        # @type {String}
        self.uid = utils.uniqueId(self.constructor.prefix)
        # @type {jQuery Element}
        self.element = $(element)
        unless self.element.length > 0
          throw new exceptions.ValueError("Element does not exist")
        # @type {Hash}              配置
        self._options = $.extend({}, self.constructor._defaults, options)
        self._updateOptions()
        # @type {Hash}              数据
        self._data = data
        # @type {Boolean}           是否允许用户交互
        self.isLocked = false
        self._skeleton()

      ###
      更新配置
      ###
      options: (options) -> if options then $.extend(this._options, options) else this._options

      ###
      更新数据
      ###
      data: (data) -> if data then $.extend(this._data, data) else this._data

      ###
      禁止用户用鼠标或手势进行交互
      ###
      lock: ->
        # TODO 从 Event 层禁止，考虑如果子类也在 element 上绑定时间的情况
        this.isLocked = true
        this

      ###
      禁止用户用鼠标、键盘或手势进行交互
      ###
      unlock: ->
        this.isLocked = false
        this

      ###
      搭建
      ###
      _skeleton: ->
        self = this
        if not self.element.data('uid')
          self.element.attr('data-uid', self.uid)
        self.element.addClass(self.constructor.prefix)

      ###
      从 HTML Element 的 data 属性上读取配置

      @param  {HTML Element}  element
      ###
      _updateOptions: ->
        for name, value of this._options
          value = this._element.data("#{this._prefix}-#{text.underscore(name)}")
          this._options[name] = value if value isnt undefined

    exports.Widget = Widget
