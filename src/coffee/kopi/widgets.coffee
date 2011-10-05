kopi.module("kopi.widgets")
  .require("kopi.utils")
  .require("kopi.utils.text")
  .require("kopi.events")
  .require("kopi.exceptions")
  .define (exports, utils, text, events, exceptions) ->
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
        super()
        # @type {String}
        this._prefix = text.underscore(this.constructor.name)
        # @type {String}
        this._id = utils.uniqueId(this._prefix)
        # @type {jQuery Element}
        this._element = $(element).attr('id', this._id)
        unless this._element.length > 0
          throw new exceptions.ValueError("Element does not exist")
        # @type {Hash}              配置
        this._options = $.extend({}, this.constructor._defaults, options)
        this._updateOptionsFromDataAttributes()
        # @type {Hash}              数据
        this._data = data

      ###
      更新配置
      ###
      options: (options={}) -> $.extend(this._options, options)

      ###
      更新数据
      ###
      data: (data={}) -> $.extend(this._data, data)

      ###
      从 HTML Element 的 data 属性上读取配置

      @param  {HTML Element}  element
      ###
      _updateOptionsFromDataAttributes: ->
        for name of this._options
          value = this._element.data("#{this._prefix)}-#{text.underscore(name)}")
          this._options[name] = value if value isnt undefined

    exports.Widget = Widget
