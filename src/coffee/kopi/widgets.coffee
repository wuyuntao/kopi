kopi.module("kopi.widgets")
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
        self.id = utils.uniqueId(self.constructor.prefix)
        # @type {jQuery Element}
        self.element = $(element)
        unless self.element.length > 0
          throw new exceptions.ValueError("Element does not exist")
        # @type {Hash}              配置
        self._options = $.extend({}, self.constructor._defaults, options)
        self._updateOptions()
        # @type {Hash}              数据
        self._data = data
        self._createSkeleton()

      ###
      更新配置
      ###
      options: (options={}) -> $.extend(this._options, options)

      ###
      更新数据
      ###
      data: (data={}) -> $.extend(this._data, data)

      ###
      搭建
      ###
      _createSkeleton: () ->
        self = this
        if not self.element.attr('id')
          self.element.attr('id', self.id)
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
