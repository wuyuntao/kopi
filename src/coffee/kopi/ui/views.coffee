kopi.module("kopi.ui.views")
  .require("kopi.exceptions")
  .require("kopi.settings")
  .require("kopi.events")
  .require("kopi.utils")
  .require("kopi.utils.html")
  .require("kopi.utils.text")
  .require("kopi.ui.templates")
  .require("kopi.ui.widgets")
  .require("kopi.ui.containers")
  .define (exports, exceptions, settings, events
                  , utils, html, text
                  , templates, widgets, containers) ->

    ###
    Manage activities of views
    ###
    class ViewContainer extends containers.Container

    ###
    View 的基类

    视图的载入应该越快越好，所以 AJAX 和数据库等 IO 操作不应该阻塞视图的显示
    ###
    class View extends containers.Content

      this.defaults
        eventTimeout: 60 * 1000     # 60 seconds

      # type  #{Boolean}  created   视图是否已创建
      created: false
      # type  #{Boolean}  started   视图是否已启动
      started: false
      # type  #{Boolean}  created   视图是否已初始化
      initialized: false
      # type  #{Boolean}  started   视图是否允许操作
      locked: false

      constructor: (path, args=[]) ->
        self = this
        self.constructor.prefix or= text.underscore(self.constructor.name)
        self.uid = utils.uniqueId(self.constructor.prefix)
        self.path = path or location.pathname
        self.args = args
        super

      create: ->
        self = this
        return self if self.created
        self.lock()
        self.emit 'create'

      start: ->
        self = this
        throw new exceptions.ValueError("Must create view first.") if not self.created
        return self if self.started
        self.lock()
        self.emit 'start'

      update: ->
        this.emit('update')

      stop: ->
        self = this
        throw new exceptions.ValueError("Must create view first.") if not self.created
        return self if not self.started
        self.lock()
        self.emit 'stop'

      destroy: ->
        self = this
        throw new exceptions.ValueError("Must stop view first.") if self.started
        return self if not self.created
        self.lock()
        self.emit 'destroy'

      ###
      事件的模板方法

      @param  {Function}    成功时的回调
      @return {Boolean|Promise}
      ###
      oncreate: (e) ->
        self = this
        self._skeleton()
        self.created = true
        self.unlock()
        self.emit 'created'

      onstart: (e) ->
        self = this
        self.started = true
        self.unlock()
        self.emit 'initialize' if not self.initialized
        self.emit 'started'

      oninitialize: (e) ->
        self = this
        self.initialized = true
        self.emit 'initialized'

      onupdate: (e) ->
        this.emit 'updated'

      onstop: (e) ->
        self = this
        self.started = false
        self.unlock()
        self.emit 'stopped'

      ondestroy: (e) ->
        self = this
        self.created = false
        self.unlock()
        self.emit 'destroyed'

    ###
    A generic view to build view from a template
    ###
    class TemplateView extends View

      template: null

      constructor: (path, args=[]) ->
        super

      _skeleton: ->
        super

        self = this
        unless self.template instanceof templates.Template
          throw new exceptions.ValueError("Template does not exists")
        self.element.html(self.template.render(self.context()))

      ###
      A template method to provide context to render template
      ###
      context: ->

    exports.ViewContainer = ViewContainer

    exports.View = View
    exports.TemplateView = TemplateView
