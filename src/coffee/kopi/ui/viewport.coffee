kopi.module("kopi.ui.viewport")
  .require("kopi.settings")
  .require("kopi.logging")
  .require("kopi.utils.browser")
  .require("kopi.ui.widgets")
  .require("kopi.ui.notification")
  .define (exports, settings, logging, browser, widgets, notification) ->

    win = $(window)

    ###
    视区

    主要用来响应窗口的大小变化

    所有需要根据窗口大小重新布局的 Widget 应该向 Viewport 注册
    当窗口大小发生变化视，视区锁屏，向所有已注册的 Widget 发送事件
    Widget 响应事件被在完成后向 Viewport 发送完成时间
    当所有 Widget 全部完成后，Viewport 将视区解锁

    TODO
    是否只是向激活的 Widget 发送事件，那如果重新载入非激活的 Widget 的时候 怎么办？

    ###
    class Viewport extends widgets.Widget

      this.RESIZE_EVENT = "resize"

      constructor: ->
        super("body", {})
        this.width = null
        this.height = null

      onskeleton: ->
        cls = this.constructor
        self = this
        self._browser()
        self.emit(cls.RESIZE_EVENT)
        # TODO Use thottle resize event of window
        win.bind cls.RESIZE_EVENT, -> self.emit(cls.RESIZE_EVENT)

      onresize: ->
        self = this
        [width, height] = [win.width(), win.height()]
        return unless width > 0 and height > 0 and self.isSizeChanged(width, height)

        logging.info("Resize viewport to #{width}x#{height}")
        notification.loading()
        self.lock()
        self.element.width(width).height(height)
        self.width = width
        self.height = height
        # TODO Notify widgets to resize and keep lock until
        # all widgets have finished resizing
        self.unlock()
        notification.loaded()

      ###
      Check if size is different from last time
      ###
      isSizeChanged: (width, height) ->
        width != this.width or height != this.height

      ###
      Add browser identify classes to viewport element
      ###
      _browser: ->
        classes = (key for key of browser when key != "version").join(" ")
        logging.debug("Add viewport classes: #{classes}")
        this.element.addClass(classes)

    exports.Viewport = Viewport
