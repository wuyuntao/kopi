define "kopi/ui/viewport", (require, exports, module) ->

  $ = require "jquery"
  exceptions = require "kopi/exceptions"
  logging = require "kopi/logging"
  browser = require "kopi/utils/browser"
  widgets = require "kopi/ui/widgets"
  notification = require "kopi/ui/notification"

  win = $(window)
  logger = logging.logger(exports.name)
  viewportInstance = null

  ###
  Viewport is reponsive to size changes of window

  ###
  class Viewport extends widgets.Widget

    this.RESIZE_EVENT = "resize"

    this.configure
      lockWhenResizing: true

    constructor: ->
      if viewportInstance
        throw new exceptions.SingletonError(this.constructor)
        return self

      viewportInstance = this
      super()
      this._options.element or= "body"
      this.width = null
      this.height = null
      this._widgets = {}

    ###

    @param {kopi.ui.Widget} widget
    @param {Boolean}        emit   Trigger resize event right after widget is registered
    ###
    register: (widget) ->
      this._widgets[widget.guid] = widget

    unregister: (widget) ->
      delete this._widgets[widget.guid]

    onskeleton: ->
      cls = this.constructor
      self = this
      self._browser()
      self._resize(false)
      # TODO Use thottle resize event of window
      win.bind cls.RESIZE_EVENT, -> self.emit(cls.RESIZE_EVENT)

    onresize: ->
      self = this
      cls = this.constructor
      self._resize(self._options.lockWhenResizing)

    ###
    所有需要根据窗口大小重新布局的 Widget 应该向 Viewport 注册
    当窗口大小发生变化视，视区锁屏，向所有已注册的 Widget 发送事件
    Widget 响应事件被在完成后向 Viewport 发送完成时间
    当所有 Widget 全部完成后，Viewport 将视区解锁
    ###
    _resize: (lock=false) ->
      self = this
      cls = this.constructor
      [width, height] = [win.width(), win.height()]
      return unless width > 0 and height > 0 and self.isSizeChanged(width, height)

      logger.info("Resize viewport to #{width}x#{height}")
      notification.loading() if lock
      self.lock()
      self.element.width(width).height(height)
      self.width = width
      self.height = height
      # Notify registered widgets to apply new size
      for guid, widget of self._widgets
        # TODO Keep lock until all widgets have finished resizing
        widget.emit(cls.RESIZE_EVENT)
      self.unlock()
      notification.loaded() if lock

    ###
    Check if size is different from last time
    ###
    isSizeChanged: (width, height) ->
      width != this.width or height != this.height

    ###
    Add browser identify classes to viewport element
    ###
    _browser: ->
      classes = (key for key in browser.all when browser[key]).join(" ")
      this.element.addClass(classes)

  Viewport: Viewport
  instance: -> viewportInstance or new Viewport()
