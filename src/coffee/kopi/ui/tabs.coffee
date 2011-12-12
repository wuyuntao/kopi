kopi.module("kopi.ui.tabs")
  .require("kopi.exceptions")
  .require("kopi.logging")
  .require("kopi.utils.array")
  .require("kopi.utils.klass")
  .require("kopi.ui.buttons")
  .require("kopi.ui.groups")
  .require("kopi.ui.widgets")
  .require("kopi.ui.scrollable")
  .define (exports, exceptions, logging, array, klass
                  , buttons, groups, widgets, scrollable) ->

    logger = logging.logger(exports.name)

    ###
    Tab errors
    ###
    class DuplicateTabKeyError extends exceptions.ValueError

      constructor: (key) ->
        super("Key has already used in tab bar: '#{key}'")

    class TabIndexError extends exceptions.ValueError

      constructor: (index) ->
          super("Tab is not found in tab bar: #{index}")

    ###
    Tab
    ###
    class Tab extends buttons.Button

      kls = this
      kls.SELECT_EVENT = "select"
      kls.UNSELECT_EVENT = "unselect"

      kls.configure
        iconPos: this.ICON_POS_TOP

      klass.accessor kls, "key"

      constructor: (tabBar, key, options) ->
        super(options)
        this._tabBar = tabBar
        this._key = key
        this._selected = false

      select: ->
        cls = this.constructor
        self = this
        return self if self._selected
        self.element.addClass(cls.cssClass("selected"))
        self._selected = true
        self.emit(cls.SELECT_EVENT)

      unselect: ->
        cls = this.constructor
        self = this
        return self if not self._selected
        self.element.removeClass(cls.cssClass("selected"))
        self._selected = false
        self.emit(cls.UNSELECT_EVENT)

      onclick: ->
        this._tabBar.select(this._key)

    ###
    Tab bar contains multiple tabs
    ###
    class TabBar extends widgets.Widget

      kls = this

      # {{{ Constant variables
      kls.LAYOUT_HORIZONTAL = "horizontal"
      kls.LAYOUT_VERTICAL = "vertical"

      # All tabs has one fixed width
      kls.STYLE_FIXED = "fixed"
      # The width of tabs decides by itself
      kls.STYLE_FLEX = "flex"
      # all tabs fills the tab bar
      kls.STYLE_EVEN = "even"

      kls.SELECT_EVENT = "select"
      kls.ADD_EVENT = "add"
      kls.REMOVE_EVENT = "remove"
      # }}}

      # {{{ Configuration
      kls.configure
        tabClass: Tab
        layout: kls.LAYOUT_VERTICAL
        style: kls.STYLE_EVEN
        width: null
        height: null
      # }}}

      # {{{ Accessors
      klass.accessor this, "tabs"
      # }}}

      ###
      @param  {Array}   tabs    Array of name/value pair
      @param  {Hash}    options
      ###
      constructor: ->
        super
        this._tabs = []
        this._keys = []
        this._selectedIndex = -1

      add: (key, options) ->
        cls = this.constructor
        self = this
        # Check if tab key is already used in tab bar
        throw new DuplicateTabKeyError(key) if key in self._keys

        tab = new self._options.tabClass(self, key, options).end(self)
        self._tabs.push(tab)
        self._keys.push(key)
        if self.initialized
          tab.skeleton().element.appendTo(self.element)
        if self.rendered
          tab.render()
        # TODO Adjust width of tabs
        self.emit(cls.ADD_EVENT)
        tab

      remove: (key) ->
        cls = this.constructor
        self = this
        index = array.indexOf(self._keys, key)
        throw new TabIndexError(index) if index == -1
        self.removeAt(index)

      removeAt: (index) ->
        self = this
        tab = self._tabs[index]
        throw new TabIndexError(index) if not tab
        tab.destroy()
        array.removeAt(self._tabs, index)
        array.removeAt(self._keys, index)
        self.emit(cls.REMOVE_EVENT)
        self

      ###
      Select a tab as if clicked.

      ###
      select: (key) ->
        self = this
        index = array.indexOf(self._keys, key)
        self._selectedIndex = index
        for tab, i in self._tabs
          if i == index then tab.select() else tab.unselect()
        self.emit(self.constructor.SELECT_EVENT, [key])

      onskeleton: ->
        cls = this.constructor
        self = this
        options = self._options

        if options.layout == cls.LAYOUT_VERTICAL
          # self.element.width(options.width) if options.width
          tabBarStyle = "height"
        else
          # self.element.height(options.height) if options.height
          tabBarStyle = "width"

        switch options.style
          when cls.STYLE_EVEN
            self._skeletonEvenTabs(tabBarStyle)
            break
          when cls.STYLE_FIXED
            self._skeletonFixedTabs(tabBarStyle)
            break
          when cls.STYLE_FLEX
            self._skeletonFlexTabs(tabBarStyle)
            break
          else
            throw new exceptions.ValueError("Unknown tab style: #{options.style}")
        super

      _skeletonEvenTabs: (style) ->
        self = this
        element = self.element
        tabsCount = self._tabs.length
        for tab in self._tabs
          tabElement = self._skeletonTab(element, tab)
          tabElement.css(style, "#{100 / tabsCount}%")
        self

      _skeletonFixedTabs: (style) ->
        self = this
        options = self._options
        element = self.element
        # TODO What about height?
        tabBarWidth = 0
        tabWidth = parseInt(self._options[style])
        for tab in self._tabs
          tabElement = self._skeletonTab(element, tab)
          tabElement[style](tabWidth))
          tabBarWidth += tabElement.outerWidth()
        self.element.width(tabBarWidth)
        self

      _skeletonFlexTabs: (element, tab, style) ->
        self = this
        element = self.element
        # TODO What about height?
        tabBarWidth = 0
        for tab in self._tabs
          tabElement = self._skeletonTab(element, tab)
          tabBarWidth += tabElement.outerWidth()
        self.element.width(tabBarWidth)
        self

      _skeletonTab: (element, tab) ->
        tab.skeleton().element.appendTo(element)

      onrender: ->
        self = this
        for tab in self._tabs
          tab.render()
        super

    ###
    A scrollable tab bar looks like Google News app on Android (horizontal)
    or bookmark panel of Firefox (vertical)

    ###
    class ScrollableTabBar extends TabBar

      kls = this
      kls.configure
        tabBarClass: TabBar
        tabBarOptions: {}
        scrollableClass :scrollable.Scrollable
        scrollableOptions: {}

      proto = kls.prototype
      klass.accessor proto, "tabBar"
      klass.accessor proto, "scrollable"

      constructor: ->
        super
        self = this
        options = self._options
        self._scrollable = new options.scrollableClass(options.scrollableOptions).end(self)
        self._tabBar = new options.tabBarClass(options.tabBarOptions).end(self)

      onskeleton: ->
        self = this
        self._scrollable.skeleton()
          .element.appendTo(self.element)
        self._tabBar.skeleton()
          .element.appendTo(self._scrollable.scroller())
        super

      onrender: ->
        self = this
        self._scrollable.render()
        self._tabBar.render()
        super

      ondestroy: ->
        self = this
        self._scrollable.destroy()
        self._tabBar.destroy()
        super

    exports.Tab = Tab
    exports.TabBar = TabBar
    exports.ScrollableTabBar = ScrollableTabBar
