kopi.module("kopi.ui.containers")
  .require("kopi.settings")
  .require("kopi.exceptions")
  .require("kopi.logging")
  .require("kopi.utils")
  .require("kopi.utils.html")
  .require("kopi.utils.text")
  .require("kopi.ui.widgets")
  .define (exports, settings, exceptions, logging, utils, html, text, widgets) ->

    PREVIOUS = "previous"
    CURRENT = "current"
    NEXT = "next"
    STATES = [PREVIOUS, CURRENT, NEXT]

    ###
    视图 和 导航栏 的基类
    ###
    class Content extends widgets.Widget

      this.defaults
        tagName: "div"

      # @type   {Hash}    A cache for css classes
      # TODO Cache frequently used css classes
      _cssClasses: {}

      state: (state) ->
        self = this
        if not state
          self.element
            .removeAttr("data-state")
            .removeClass((self.constructor.cssClass(name) for name in STATES).join(" "))

          return

        if state not in STATES
          throw new exceptions.ValueError("Not a valid state name: #{state}")

        self.element.attr("data-state", state)
          .removeClass((self.constructor.cssClass(name) for name in STATES when name != state).join(" "))
          .addClass(self.constructor.cssClass(state))

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
        contentClass: widgets.Widget
        className: "kopi-container"
        # @type   {Number}    Timeout for transition
        timeout: 5000


      # @type   {Hash<UID, Content>}  内容缓存
      cache: {}
      # @type   {Hash<UID, Content>}  内容缓存
      contents: {}
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
        unless content instanceof Content
          throw new exceptions.ValueError("Must be an instance of Content.")

        self = this
        # TODO 有锁的情况下把请求加入队列？
        if self.isLocked
          logging.warn("Container is locked and will not handle this action.")
          return self

        self.lock()
        self.append(content, true)
        self.element.addClass(self.constructor.cssClass("transition"))
        self.emit('transit', [reverse])
        # onTimeout = -> self.emit('transitiontimeout')
        # clearTimeout(self._timeout) if self._timeout
        # self._timeout = setTimeout(onTimeout, self._options.timeout)

      append: (content, next=true) ->
        self = this
        if not self.contains(content)
          self.element.append(content.element)
          self.cache[content.uid] = content
        if next
          self.contents.next.state(null) if self.contents.next
          content.state(NEXT)
          self.contents.next = content

      ###
      Check if content is already appended to container

      @param  {Content}   content
      ###
      contains: (content) ->
        content.uid of this.cache

      ###
      在子类中重写这个方法以实现切入动画，如 slide-in-out, slide-up-down, flip-in-out 等
      ###
      ontransit: (event, reverse) ->
        if not this.contents.current
          this.contents.next.element.show()
        else
          this.contents.current.element.fadeOut()
          this.contents.next.element.fadeIn()
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

        if self.contents.previous
          self.contents.previous.state(null)

        if self.contents.current
          self.contents.current.state(PREVIOUS)
          self.contents.previous = self.contents.current

        if self.contents.next
          self.contents.next.state(CURRENT)
          self.contents.current = self.contents.next
          self.contents.next = null

        self.unlock()

      ontransitiontimeout: (event, content, reverse) ->
        this.emit('transitioncomplete')
        return

    exports.Container = Container
    exports.Content = Content
