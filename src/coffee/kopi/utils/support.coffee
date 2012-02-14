kopi.module("kopi.utils.support")
  .require("kopi.utils.object")
  .require("kopi.utils.browser")
  .define (exports, object, browser) ->

    # Caches for global variables
    win = window
    hist = win.history
    doc = document
    docElem = doc.documentElement
    docMode = doc.documentMode

    fakeBody = $("<body>").prependTo("html")
    fbCSS = fakeBody[0].style
    cssPrefixes = ["-webkit-", "-moz-", "-o-", "-ms-", "-khtml-"]
    domPrefixes = ["Webkit", "Moz", "O", "ms", "Khtml"]

    ###
    testProps is a generic CSS / DOM property test; if a browser supports
      a certain property, it won't return undefined for it.
      A supported CSS property returns empty string when its not yet set.
    ###
    testProps = (props) ->
      for prop in props
        if fbCSS[prop] isnt undefined
          return true
      false

    ###
    testPropsAll tests a list of DOM properties we want to check against.
      We specify literally ALL possible (known and/or likely) properties
      on the element including the non-vendor prefixed one, for forward-
      compatibility.
    ###
    testPropsAll = (prop) ->
      ucProp = prop.charAt(0).toUpperCase() + prop.substr(1)
      props = (prop + " " + domPrefixes.join(ucProp + " ") + ucProp).split(" ")
      testProps(props)

    object.extend exports, $.support,
      # Does the browser support window.onhashchange? Note that IE8 running in
      # IE7 compatibility mode reports true for "onhashchange" in window, even
      # though the event isn"t supported, so also test document.documentMode.
      hash: "onhashchange" of win and (docMode == undefined or docMode > 7)

      # 是否支持 HTML5 历史
      history: "pushState" of hist and "replaceState" of hist

      # pageShow: "onpageshow" in win and "onpagehide" in win

      # 是否支持 本地 Key/Value 存储
      storage: "localStorage" of win

      # 是否支持 HTML5 离线缓存
      cache: "applicationCache" of win

      # 是否支持 HTML5 WebSQL 数据库
      websql: "openDatabase" of win

      # Vendors had inconsistent prefixing with the experimental Indexed DB:
      # - Webkit's implementation is accessible through webkitIndexedDB
      # - Firefox shipped moz_indexedDB before FF4b9, but since then has been mozIndexedDB
      indexedDB: testPropsAll("indexedDB")

      # 在某些设备（如 HTC Desire）上，orientationchange 事件工作不正常，
      # 事件被触发时，window 的大小还没有改变
      # 参考
      # https://github.com/jquery/jquery-mobile/issues/793
      orientation: false

      # 是否支持原生触摸事件
      touch: "ontouchend" of doc

      cssMatrix: "WebKitCSSMatrix" of win and "m11" of new WebKitCSSMatrix()

      cssTransform: testProps(['transformProperty', 'WebkitTransform', 'MozTransform', 'OTransform', 'msTransform'])

      cssTransform3d: testProps(['perspectiveProperty', 'WebkitPerspective', 'MozPerspective', 'OPerspective', 'msPerspective'])

      cssTransition: testPropsAll("transitionProperty")

    fakeBody.remove()
