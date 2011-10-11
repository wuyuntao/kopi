kopi.module("kopi.core.manager")
  .require("kopi.core.router")
  .require("kopi.events")
  .require("kopi.utils")
  .require("kopi.utils.text")
  .require("kopi.utils.support")
  .require("kopi.exceptions")
  .require("kopi.ui.views")
  .define (exports, router, events, utils, text, support, exceptions, views) ->

    class State
      this.fromJSON = (json={}) ->
        new this(json.url, json.view, json.context, json.uid)

      constructor: (url, view, context={}, id=null) ->
        throw exceptions.ValueError("Must have URL") unless url
        throw exceptions.ValueError("Must have View") unless view and view instanceof views.View

        this.uid = id or utils.uniqueId(this.constructor.name)
        this.url = url
        this.view = view
        this.context = context

      equals: (state) -> this.uid == state.uid

    ###
    响应 URL 变化和管理视图切换的控制器
    ###
    class Manager extends events.EventEmitter

      # @type {State}       当前状态
      currentState: null

      # @type {Boolean}     是否接受状态改变
      stateLock: false

      # @type {Hash<URL, State>}
      stateStack: {}

      constructor: ->
        self = this
        self.start()

      ###
      开动 URL 变化监听
      ###
      start: ->
        self = this
        # self.views = new views.ViewContainer()
        ###
        self.emit 'start'
        if support.pushState
          $(window).bind 'popstate', (e) ->
            if e.state.id
              self.emit 'change', [State.fromJSON(e.state)]
            else
              url = location.href
              view = router.match(url)
              if view
                self.emit 'change', [new State(url, view)]
        else
          throw new exceptions.NotImplementedError()
        ###

      ###
      获取当前页面的 URL

      TODO 格式化 URL
      ###
      getCurrentURL: ->
        location.pathname

      load: (url) ->
        self = this
        url or= this.getCurrentURL()
        # # 在缓存中查找已经创建过的 View
        # if url of this.stateStack
        #   state = this.stateStack[url]
        #   view = state.view.start (view) ->
        match = router.match(url)
        if match
          view = new match.route.view(match.args...)
          self.views.start(view)
        self

        ###
        self = this
        stateManager.one 'load', (state) ->
          match = router.matches(state.path)
          if match
            currentView = new match.route.view(match.args...)
            currentView.start (view) ->

              onChange = (state) ->
                changeLock = true
                stateManager.unbind 'change', onChange
                match = router.matches(state.path)
                if match
                  view = new match.route.view(match.args...)
                  $.when(currentView.stop(view), view.start(currentView))
                    .done ->
                      currentView = view
                      changeLock = false
                      stateManager.bind 'change', onChange

              stateManager.bind 'change', onChange
        ###

      onstart: (e) ->
        ###
        url = location.href
        state = this.match(url)
        # if state
        view = router.match(url)
        if view
          view.create (view) ->
            view.start (view) ->
        ###

      onchange: (e, state) ->

      # 在缓存中寻找 View
      match: (url) ->

    # Manager 单例
    manager = new Manager()

    start = ->
      manager or= new Manager()

    load = (url) ->
      throw new exceptions.ValueError("Start manager first.") unless manager
      manager.load(arguments...)

    exports.start = start
    exports.load = load
