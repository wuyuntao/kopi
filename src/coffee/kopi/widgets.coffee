kopi.module("kopi.widgets")
  .require("kopi.utils")
  .define (exports, utils) ->
    ###
    UI 组件的基类
    ###
    class Widget
      defaults: {}

      constructor: (element, options={}, data={}) ->
        this._id = utils.uniqueId(this.name)
        this._element = $(element).attr('id', this.id)
        this._options = $.extend(this.defaults, options)
        this._data = data
        throw new Error("Element does not exist") unless this.element.length > 0

      options: (options={}) -> $.extend this._options, options

      data: (data={}) -> $.extend this._data, data
