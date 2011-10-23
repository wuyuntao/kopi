kopi.module("kopi.ui.containers")
  .require("kopi.settings")
  .require("kopi.exceptions")
  .require("kopi.logging")
  .require("kopi.utils")
  .require("kopi.utils.html")
  .require("kopi.utils.text")
  .require("kopi.ui.widgets")
  .require("kopi.ui.contents")
  .define (exports, settings, exceptions, logging, utils, html, text, widgets, contents) ->

    ###
    管理 视图 和 导航栏 的容器基类

    div.container
      div.container-content
      div.container-content[data-state=previous]
      div.container-content[data-state=current]
      div.container-content[data-state=next]
      div.container-content
    ###
    class Container extends widgets.Widget

      this.defaults
        autoSkeleton: true
        # @type   {Number}    Timeout for transition
        # timeout: 5000

      # @type   {Hash<UID, Content>}  内容缓存
      _cache: {}
      # @type   {Hash<UID, Content>}  内容缓存
      _contents: {}
      # @type   {Number}              Timeout ID
      _timeout: null

      # @type {Array<Content>}  曾经显示过的内容历史
      # _history: []

      # @type {Array<Content>}  预备显示过的内容队列
      # _queue: []

      ###
      如果 reverse 为 false，把内容加到 next 容器中，并显示
      反之则加到 previous 容器中并显示
      ###
      load: (content, reverse=false) ->
        unless content instanceof contents.Content
          throw new exceptions.ValueError("Must be an instance of Content.")

        self = this
        # TODO 有锁的情况下把请求加入队列？
        if self.locked
          logging.warn("Container is locked and will not handle this action.")
          return self

        self.lock()
        self.append(content, true)
        self.element.addClass(self.constructor.cssClass("transition"))
        self.emit('transit', [reverse])
        # onTimeout = -> self.emit('transitiontimeout')
        # clearTimeout(self._timeout) if self._timeout
        # self._timeout = setTimeout(onTimeout, self._options.timeout)

      hide: ->

      append: (content, next=true) ->
        self = this
        if not self.contains(content)
          self.element.append(content.element)
          self._cache[content.uid] = content
        if next
          self._contents.next.background() if self._contents.next
          content.next()
          self._contents.next = content

      ###
      Check if content is already appended to container

      @param  {Content}   content
      ###
      contains: (content) ->
        content.uid of this._cache

      ###
      在子类中重写这个方法以实现切入动画，如 slide-in-out, slide-up-down, flip-in-out 等
      ###
      ontransit: (event, reverse) ->
        if not this._contents.current
          this._contents.next.element.show()
        else
          this._contents.current.element.fadeOut()
          this._contents.next.element.fadeIn()
        this.emit('transitioncomplete')
        return

      ###
      当 Transition 结束后，轮换 css class 名称
      ###
      ontransitioncomplete: (event, content, reverse) ->
        self = this
        self.element.removeClass(self.constructor.cssClass("transition"))
        # if self._timeout
        #   clearTimeout(self._timeout)
        #   self._timeout = null

        if self._contents.previous
          self._contents.previous.background()

        if self._contents.current
          self._contents.current.previous()
          self._contents.previous = self._contents.current

        if self._contents.next
          self._contents.next.current()
          self._contents.current = self._contents.next
          self._contents.next = null

        self.unlock()

      ontransitiontimeout: (event, content, reverse) ->
        this.emit('transitioncomplete')
        return

    exports.Container = Container
