kopi.module("kopi.core")
  .require("kopi.core.routers")
  .define (exports, routers) ->
    router = routers.router
    ###
    响应 URL 变化和管理视图切换的控制器
    ###
    class Manager
      currentView = null
      changeLock = false

      constructor: ->
        self = this
        # 第一次载入页面时，根据页面的 Path 找到 View
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

    exports.manager = new Manager()
