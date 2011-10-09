kopi.module("kopi.views")
  .require("kopi.settings")
  .require("kopi.events")
  .require("kopi.utils")
  .require("kopi.utils.html")
  .require("kopi.utils.text")
  .require("kopi.widgets")
  .define (exports, settings, events, utils, html, text, widgets) ->

    ###
    View 的容器
    ###
    class ViewContainer extends widgets.Widget

      currentView = null

      constructor: (element=settings.kopi.viewContainerSelector) ->
        super(element)

      start: (view) ->
        self = this
        if not view.created
          view.create()
          view.element.appendTo(self.element)

    ###
    View 的基类

    视图的载入应该越快越好，所以 AJAX 和数据库等 IO 操作不应该阻塞视图的显示
    ###
    class View extends events.EventEmitter

      # type  #{Boolean}  created   视图是否已创建
      created: false
      # type  #{Boolean}  started   视图是否已启动
      started: false
      # type  #{Boolean}  started   视图是否允许操作
      locked: false

      constructor: (container, path, args=[]) ->
        self = this
        self.container = container
        self.constructor.prefix or= text.underscore(self.constructor.name)
        self.id = utils.uniqueId(self.constructor.prefix)
        self.path = path or location.pathname
        self.args = args

      create: ->
        self = this
        return self if self.created
        self._createSkeleton()
        self.created = true
        self.emit('create')

      start: ->
        self = this
        throw new ValueError("Must create view first.") if not self.created
        return self if self.started
        self.started = true
        self.onstart()

      update: ->
        this.onupdate()

      stop: ->
        self = this
        throw new ValueError("Must create view first.") if not self.created
        return self if not self.started
        self.started = false
        self.onstop()

      destroy: ->
        self = this
        throw new ValueError("Must stop view first.") if self.started
        return self if not self.created
        self.created = false
        self.ondestroy()

      # TODO 阻止 UI 操作
      lock: () ->
        self = this
        return self if self.locked
        self.locked = true
        self.onunlock()
        self

      unlock: () ->
        self = this
        return self unless self.locked
        self.locked = false
        self.onlock()
        self

      _createSkeleton: ->
        this.element = html.build 'div',
                          id: this.id,
                          class: this.constructor.prefix

      ###
      事件的模板方法

      @param  {Function}    成功时的回调
      @return {Boolean|Promise}
      ###
      oncreate:  () -> true
      onstart:   () -> true
      onupdate:  () -> true
      onstop:    () -> true
      ondestroy: () -> true
      onlock:    () -> true
      onunlock:  () -> true

    exports.ViewContainer = ViewContainer
    exports.View = View
