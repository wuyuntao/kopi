kopi.module("kopi.ui.tabs")
  .require("kopi.exceptions")
  .require("kopi.utils.array")
  .require("kopi.utils.klass")
  .require("kopi.ui.buttons")
  .require("kopi.ui.groups")
  .require("kopi.ui.widgets")
  .require("kopi.ui.scrollable")
  .define (exports, exceptions, array, klass
                  , buttons, groups, widgets, scrollable) ->

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

      kls.configure
        iconPos: this.ICON_POS_TOP

      klass.accessor kls, "key"

      constructor: (tabBar, key, options) ->
        super(options)
        this._tabBar = tabBar
        this._key = key
        this._selected = false

      end: -> this._tabBar

      select: ->
        cls = this.constructor
        self = this
        return self if self._selected
        self.element.addClass(cls.cssClass("selected"))
        self._selected = true
        self.emit("select")

      unselect: ->
        cls = this.constructor
        self = this
        return self if not self._selected
        self.element.removeClass(cls.cssClass("selected"))
        self.selected = false
        self.emit("unselect")

      onclick: ->
        this._tabBar.select(this._key)

    ###
    Tab bar contains multiple tabs
    ###
    class TabBar extends widgets.Widget

      this.configure
        tabClass: Tab

      klass.accessor this, "tabs"

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
        self = this
        # Check if tab key is already used in tab bar
        throw new DuplicateTabKeyError(key) if key in self._keys

        tab = new self._options.tabClass(self, key, options).skeleton()
        tab.element.appendTo(self.element)
        self._tabs.push(tab)
        self._keys.push(key)
        tab

      remove: (key) ->
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
        self.emit("select", [key])

      onskeleton: ->
        self = this
        for tab in self._tabs
          tab.skeleton().element.appendTo(self.element)
        super

      onrender: ->
        self = this
        for tab in self._tabs
          tab.render()
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
