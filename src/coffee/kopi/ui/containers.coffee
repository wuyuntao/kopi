kopi.module("kopi.ui.containers")
  .require("kopi.settings")
  .require("kopi.exceptions")
  .require("kopi.logging")
  .require("kopi.utils")
  .require("kopi.utils.html")
  .require("kopi.utils.text")
  .require("kopi.ui.widgets")
  .define (exports, settings, exceptions, logging,
                    utils, html, text, widgets) ->

    ###
    管理 视图 和 导航栏 的容器基类

    div.container
      div.container-content-previous
      div.container-content-current
      div.container-content-next
    ###
    class Container extends widgets.Widget

      this.defaults
        containerClassName: "container"
        contentWidget: widgets.Widget
        contentClassNamePrefix: "container-content-"
        contentNames: ["previous", "current", "next"]
        contentTagName: "div"

      # @type {String}  前一次显示的内容 uid
      _previous: null
      # @type {String}  当前显示的内容 uid
      _current: null
      # @type {String}  下一次显示的内容 uid
      _next: null

      # @type {Hash<UID, Content>}  内容缓存
      # _cache: {}

      # @type {Array<Content>}  曾经显示过的内容历史
      # _history: []

      # @type {Array<Content>}  预备显示过的内容队列
      # _queue: []

      ###
      如果 reverse 为 false，把内容加到 next 容器中，并显示
      反之则加到 previous 容器中并显示
      ###
      switch: (content, reverse=false, callback) ->
        unless content instanceof this._options.contentWidget
          throw new exceptions.ValueError("Content must be a #{this.options.contentWidget.name}.")

        self = this
        # TODO 有锁的情况下把请求加入队列？
        if self.isLocked
          logging.warn("Container is locked and will not handle this action.")
          return self

        self.lock()
        # self.emit('transition')

        # 把内容加入下一次显示的容器
        # self._cache[content.uid] = content
        prefix = this._options.contentClassNamePrefix

        # 如果是第一次显示的话直接插入 Current 容器
        # if not self._current
        #   self.contents.current.html(content.element).show()
        #   self._current = content
        #   self.emit('transitionend')
        # else
        #   self._transit content, reverse, () ->
        #     self.emit('transitionend')
        self._add(content, if reverse then 'previous' else 'next')
        self[if reverse then 'back' else 'forward']()

      ###
      显示 next 容器中内容
      ###
      forward: (callback) ->
        this._transit(false, callback)

      ###
      显示 previous 容器中内容
      ###
      back: (callback) ->
        this._transit(true, callback)

      _add: (content, name) ->
        self.contents[name].html(content.element)
        self["_#{name}"] = content

      ###
      在子类中重写这个方法以实现切入动画，如 slide-in-out, slide-up-down, flip-in-out 等
      ###
      _transit: (reverse=false, callback) ->
        _rotate(reverse)
        callback()
        return

      ###
      当 Transition 结束后，轮换 css class 名称
      ###
      _rotate: (reverse=false) ->
        self = this
        # TODO Rewrite
        if reverse
          # 把 current 放到 next
          self._current = self._next
          self.contents.next.html(self._current.element)
          # 把 previous 放到 current
          self._previous = self._current
          self.contents.current.html(self._previous.element)
        else
          # 把 current 放到 previous
          self._current = self._previous
          self.contents.previous.html(self._current.element)
          # 把 next 放到 current
          self._next = self._current
          self.contents.current.html(self._next.element)

      _skeleton: ->
        super
        self = this
        options = self._options
        self.contents = {}
        for name, i in options.contentNames
          content = html.build(options.contentTagName, class: options.contentClassNamePrefix + name)
          content.appendTo(self.element)
          self.contents[name] = content

      # Event templates
      ontransition:     -> true
      ontransitionend:  -> true

    exports.Container = Container
