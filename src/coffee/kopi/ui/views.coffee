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

      # type  #{Boolean}  created   视图是否已创建
      created: false
      # type  #{Boolean}  started   视图是否已启动
      started: false
      # type  #{Boolean}  started   视图是否允许操作
      locked: false

      constructor: (path, args=[]) ->
        self = this
        self.constructor.prefix or= text.underscore(self.constructor.name)
        self.uid = utils.uniqueId(self.constructor.prefix)
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
        throw new exceptions.ValueError("Must create view first.") if not self.created
        return self if self.started
        self.started = true
        self.onstart()

      update: ->
        this.onupdate()

      stop: ->
        self = this
        throw new exceptions.ValueError("Must create view first.") if not self.created
        return self if not self.started
        self.started = false
        self.onstop()

      destroy: ->
        self = this
        throw new exceptions.ValueError("Must stop view first.") if self.started
        return self if not self.created
        self.created = false
        self.ondestroy()

      ###
      事件的模板方法

      @param  {Function}    成功时的回调
      @return {Boolean|Promise}
      ###
      oncreate:  -> true
      onstart:   -> true
      onupdate:  -> true
      onstop:    -> true
      ondestroy: -> true

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
