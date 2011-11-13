kopi.module("kopi.utils.support")
  .require("kopi.utils.object")
  .define (exports, object) ->
    # Caches for global variables
    win = window
    hist = window.history
    doc = document
    docMode = doc.documentMode

    fakeBody = $("<body>").prependTo("html")
    fbCSS = fakeBody[0].style
    vendors = ["webkit", "moz", "o"]

    # thx Modernizr
    propExists = (prop) ->
        ucProp = prop.charAt(0).toUpperCase() + prop.substr(1)
        props = (prop + " " + vendors.join(ucProp + " ") + ucProp).split(" ")
        for value of props
            return true if fbCSS[value] isnt undefined
        false

    object.extend exports, $.support,
      # Does the browser support window.onhashchange? Note that IE8 running in
      # IE7 compatibility mode reports true for "onhashchange" in window, even
      # though the event isn"t supported, so also test document.documentMode.
      hash: "onhashchange" of win and (docMode == undefined or docMode > 7)

      # 是否支持 HTML5 历史
      history: "pushState" of hist and "replaceState" of hist

      # pageShow: "onpageshow" in win and "onpagehide" in win

      # 是否支持 本地 Key/Value 存储
      storage: "localStorage" of window

      # 是否支持 HTML5 离线缓存
      cache: "applicationCache" of window

      # 是否支持 HTML5 WebSQL 数据库
      websql: "openDatabase" of window

      # 在某些设备（如 HTC Desire）上，orientationchange 事件工作不正常，
      # 事件被触发时，window 的大小还没有改变
      # 参考
      # https://github.com/jquery/jquery-mobile/issues/793
      orientation: false

      # 是否支持原生触摸事件
      touch: "ontouchend" of document

      # 是否支持 CSS 动画
      # TODO 加入 Firefox 和 Opera 的判断
      cssTransitions: "WebKitTransitionEvent" of window

    fakeBody.remove()
