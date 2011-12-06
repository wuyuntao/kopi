kopi.module("kopi.ui.tabs")
  .require("kopi.utils.klass")
  .require("kopi.ui.buttons")
  .require("kopi.ui.groups")
  .require("kopi.ui.widgets")
  .require("kopi.ui.scrollable")
  .define (exports, klass, buttons, groups, widgets, scrollable) ->

    class Tab extends buttons.Button

      constructor: (tabBar, options) ->
        super(options)
        this._tabBar = tabBar

    class Panel extends widgets.Widget

      constructor: (tabBar, options) ->
        super(options)
        this._tabBar = tabBar

    class TabBar extends widgets.Widget

      klass.accessor "tabs"

      ###
      @param  {Array}   tabs    Array of name/value pair
      @param  {Hash}    options
      ###
      constructor: ->
        super
        this._tabs = []

      add: ->

      remove: ->

      ###
      Select a tab as if clicked.

      ###
      select: () ->

      onskeleton: ->
        # TODO Append tabs to element
        super

    class ScrollableTabBar extends TabBar

      this.configure
        tabClass: Tab

      onskeleton: ->
        self = this
        self._scrollable = new scrollable.Scrollable()
        # TODO Append tabs to scrollable
        # TODO Append scrollable to element
        super

    exports.Tab = Tab
    exports.TabBar = TabBar
    exports.ScrollableTabBar = ScrollableTabBar
