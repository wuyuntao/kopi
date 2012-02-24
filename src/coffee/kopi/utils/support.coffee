define "kopi/utils/support", (require, exports, module) ->

  $ = require "jquery"
  object = require "kopi/utils/object"
  browser = require "kopi/utils/browser"

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
  lowerDomPrefixes = ["webkit", "moz", "o", "ms", "khtml"]

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

  getProp = (prop, target=win) ->
    ucProp = prop.charAt(0).toUpperCase() + prop.substr(1)
    props = (prop + " " + lowerDomPrefixes.join(ucProp + " ") + ucProp).split(" ")
    for prop in props
      if target[prop] isnt undefined
        return target[prop]

  ###
  Expose verdor-specific IndexedDB objects
  ###
  win.indexedDB or= getProp("indexedDB")
  win.IDBTransaction or= getProp("IDBTransaction")
  win.IDBKeyRange or= getProp("IDBKeyRange")
  win.IDBCursor or= getProp("IDBCursor")

  object.extend exports, $.support,
    # Does the browser support window.onhashchange? Note that IE8 running in
    # IE7 compatibility mode reports true for "onhashchange" in window, even
    # though the event isn"t supported, so also test document.documentMode.
    hash: "onhashchange" of win and (docMode == undefined or docMode > 7)

    history: "pushState" of hist and "replaceState" of hist

    # pageShow: "onpageshow" of win and "onpagehide" of win

    storage: "localStorage" of win

    cache: "applicationCache" of win

    websql: "openDatabase" of win

    # Vendors had inconsistent prefixing with the experimental Indexed DB:
    # - Webkit's implementation is accessible through webkitIndexedDB
    # - Firefox shipped moz_indexedDB before FF4b9, but since then has been mozIndexedDB
    indexedDB: !!win.indexedDB

    orientation: "onorientationchange" of win

    # 是否支持原生触摸事件
    touch: "ontouchend" of doc

    cssMatrix: "WebKitCSSMatrix" of win and "m11" of new WebKitCSSMatrix()

    cssTransform: testProps(['transformProperty', 'WebkitTransform', 'MozTransform', 'OTransform', 'msTransform'])

    cssTransform3d: testProps(['perspectiveProperty', 'WebkitPerspective', 'MozPerspective', 'OPerspective', 'msPerspective'])

    cssTransition: testPropsAll("transitionProperty")

    prop: getProp

  fakeBody.remove()

  return
