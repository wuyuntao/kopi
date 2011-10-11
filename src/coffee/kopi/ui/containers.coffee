kopi.module("kopi.ui.containers")
  .require("kopi.settings")
  .require("kopi.exceptions")
  .require("kopi.utils")
  .require("kopi.utils.html")
  .require("kopi.utils.text")
  .require("kopi.ui.widgets")
  .define (exports, settings, exceptions, utils, html, text, widgets) ->

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

      switch: (content, reverse=false) ->
        unless content instanceof widgets.Widget
          throw new exceptions.ValueError("Content must be a widget.")

        self = this
        # TODO 有锁的情况下把请求加入队列？
        return self if self.isLocked

        self.lock()
        self.emit('transition')

        # 把内容加入下一次显示的容器
        # self._cache[content.uid] = content
        prefix = this._options.contentClassNamePrefix

        # 如果是第一次显示的话直接插入 Current 容器
        if not self._current
          self.contents.current.html(content.element).show()
          self._current = content
          self.emit('transitionend')
        else
          self._transit content, reverse, () ->
            self.emit('transitionend')

      ###
      在子类中重写这个方法以实现切入动画，如 slide-in-out, slide-up-down, flip-in-out 等
      ###
      _transit: (content, reverse, callback) ->
        callback()
        return

      ###
      轮换 css class 名称
      ###
      _rotate: (reverse=false) ->
        self = this
        prefix = self._options.contentClassNamePrefix
        # FIXME Rewrite
        self.contents.previous.removeClass(prefix + "previous").addClass(prefix + (if reverse then "current" else "next"))
        self.contents.current.removeClass(prefix + "current").addClass(prefix + (if reverse then "next" else "previous"))
        self.contents.next.removeClass(prefix + "next").addClass(prefix + (if reverse then "previous" else "current"))

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
