(function() {

  define("kopi/utils/support", function(require, exports, module) {
    var $, browser, cssPrefixes, doc, docElem, docMode, domPrefixes, fakeBody, fbCSS, getProp, hist, lowerDomPrefixes, object, testProps, testPropsAll, win;
    $ = require("jquery");
    object = require("kopi/utils/object");
    browser = require("kopi/utils/browser");
    win = window;
    hist = win.history;
    doc = document;
    docElem = doc.documentElement;
    docMode = doc.documentMode;
    fakeBody = $("<body>").prependTo("html");
    fbCSS = fakeBody[0].style;
    cssPrefixes = ["-webkit-", "-moz-", "-o-", "-ms-", "-khtml-"];
    domPrefixes = ["Webkit", "Moz", "O", "ms", "Khtml"];
    lowerDomPrefixes = ["webkit", "moz", "o", "ms", "khtml"];
    /*
      testProps is a generic CSS / DOM property test; if a browser supports
        a certain property, it won't return undefined for it.
        A supported CSS property returns empty string when its not yet set.
    */

    testProps = function(props) {
      var prop, _i, _len;
      for (_i = 0, _len = props.length; _i < _len; _i++) {
        prop = props[_i];
        if (fbCSS[prop] !== void 0) {
          return true;
        }
      }
      return false;
    };
    /*
      testPropsAll tests a list of DOM properties we want to check against.
        We specify literally ALL possible (known and/or likely) properties
        on the element including the non-vendor prefixed one, for forward-
        compatibility.
    */

    testPropsAll = function(prop) {
      var props, ucProp;
      ucProp = prop.charAt(0).toUpperCase() + prop.substr(1);
      props = (prop + " " + domPrefixes.join(ucProp + " ") + ucProp).split(" ");
      return testProps(props);
    };
    getProp = function(prop, target) {
      var props, ucProp, _i, _len;
      if (target == null) {
        target = win;
      }
      ucProp = prop.charAt(0).toUpperCase() + prop.substr(1);
      props = (prop + " " + lowerDomPrefixes.join(ucProp + " ") + ucProp).split(" ");
      for (_i = 0, _len = props.length; _i < _len; _i++) {
        prop = props[_i];
        if (target[prop] !== void 0) {
          return target[prop];
        }
      }
    };
    /*
      Expose verdor-specific IndexedDB objects
    */

    win.indexedDB || (win.indexedDB = getProp("indexedDB"));
    win.IDBTransaction || (win.IDBTransaction = getProp("IDBTransaction"));
    win.IDBKeyRange || (win.IDBKeyRange = getProp("IDBKeyRange"));
    win.IDBCursor || (win.IDBCursor = getProp("IDBCursor"));
    object.extend(exports, $.support, {
      hash: "onhashchange" in win && (docMode === void 0 || docMode > 7),
      history: "pushState" in hist && "replaceState" in hist,
      storage: "localStorage" in win,
      cache: "applicationCache" in win,
      websql: "openDatabase" in win,
      indexedDB: !!win.indexedDB,
      orientation: "onorientationchange" in win,
      touch: "ontouchend" in doc,
      cssMatrix: "WebKitCSSMatrix" in win && "m11" in new WebKitCSSMatrix(),
      cssTransform: testProps(['transformProperty', 'WebkitTransform', 'MozTransform', 'OTransform', 'msTransform']),
      cssTransform3d: testProps(['perspectiveProperty', 'WebkitPerspective', 'MozPerspective', 'OPerspective', 'msPerspective']),
      cssTransition: testPropsAll("transitionProperty"),
      prop: getProp
    });
    fakeBody.remove();
  });

}).call(this);
