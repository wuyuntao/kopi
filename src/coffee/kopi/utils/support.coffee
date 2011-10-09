kopi.module("kopi.utils.support")
  .require("kopi.utils")
  .define (exports, utils) ->
    # Caches for global variables
    win = window
    hist = window.history
    docMode = document.documentMode

    utils.extend exports, $.support,
      # Does the browser support window.onhashchange? Note that IE8 running in
      # IE7 compatibility mode reports true for 'onhashchange' in window, even
      # though the event isn't supported, so also test document.documentMode.
      hashChange: 'onhashchange' in win and (docMode === undefined or docMode > 7)

	    pushState: "pushState" in hist and "replaceState" in hist

      # pageShow: "onpageshow" in win and "onpagehide" in win
