define "kopi/ui/viewport", (require, exports, module) ->

  $ = require "jquery"
  exceptions = require "kopi/exceptions"
  logging = require "kopi/logging"
  browser = require "kopi/utils/browser"
  widgets = require "kopi/ui/widgets"
  notification = require "kopi/ui/notification"

  win = $(window)
  logger = logging.logger(module.id)
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
      this._listeners = {}

    ###

    @param {kopi.ui.Widget} widget
    @param {Boolean}        emit   Trigger resize event right after widget is registered
    ###
    register: (widget) ->
      this._listeners[widget.guid] = widget
      this

    unregister: (widget) ->
      delete this._listeners[widget.guid]
      this

    onskeleton: ->
      cls = this.constructor
      self = this
      self._browser()
      self._resize(false)
      # TODO Use thottle resize event of window
      win.bind cls.RESIZE_EVENT, -> self.emit(cls.RESIZE_EVENT)
      super

    onresize: ->
      self = this
      cls = this.constructor
      # TODO Do not send resize events immediately when app is locked?
      self._resize(self._options.lockWhenResizing)

    ###
    Widgets which is reponsive to window size, should register itself to viewport.
    When viewport receives window resize event, it will pass event to registered
    widgets properly
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
      for guid, widget of self._listeners
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
