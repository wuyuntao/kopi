define "kopi/ui/tabs", (require, exports, module) ->

  exceptions = require "kopi/exceptions"
  logging = require "kopi/logging"
  array = require "kopi/utils/array"
  klass = require "kopi/utils/klass"
  text = require "kopi/utils/text"
  buttons = require "kopi/ui/buttons"
  groups = require "kopi/ui/groups"
  widgets = require "kopi/ui/widgets"
  scrollable = require "kopi/ui/scrollable"

  logger = logging.logger(module.id)

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

    kls.widgetName "Tab"

    kls.configure
      hasIcon: true
      iconWidth: 24
      iconHeight: 24
      iconPos: this.ICON_POS_TOP

    klass.accessor kls.prototype, "key"

    constructor: (options) ->
      super(options)
      this._key or= this.guid
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

  TODO Inherit from some button group
  ###
  class TabBar extends groups.Group

    kls = this

    kls.widgetName "TabBar"

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
      childClass: Tab
      layout: kls.LAYOUT_HORIZONTAL
      style: kls.STYLE_EVEN
      width: null
      height: null
    # }}}

    # {{{ Accessors
    klass.accessor this, "tabs",
      name: "children"
    # }}}

    ###
    @param  {Array}   tabs    Array of name/value pair
    @param  {Hash}    options
    ###
    constructor: (options) ->
      super
      cls = this.constructor
      this._selectedIndex = -1
      this._options.extraClass += " #{cls.cssClass(this._options.layout)} #{cls.cssClass(this._options.style)}"

    _wrapper: ->
      this.element

    # TODO Add some method to add/remove tab by its key
    # addByKey
    # addAtByKey
    # removeByKey
    # removeAtByKey

    ###
    Select a tab as if clicked.

    ###
    select: (key) ->
      self = this
      index = array.indexOf(self._keys, key)
      self._selectedIndex = index
      for tab, i in self._children
        if i == index then tab.select() else tab.unselect()
      self.emit(self.constructor.SELECT_EVENT, [key])

    onskeleton: ->
      cls = this.constructor
      self = this
      options = self._options

      if options.layout == cls.LAYOUT_VERTICAL
        tabBarStyle = "height"
      else
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
      element = self._wrapper()
      tabsCount = self._children.length
      for tab in self._children
        tabElement = self._skeletonTab(element, tab)
        tabElement.css(style, "#{100 / tabsCount}%")
      self

    _skeletonFixedTabs: (style) ->
      self = this
      options = self._options
      element = self._wrapper()
      tabBarSize = 0
      tabSize = parseInt(self._options[style])
      outerStyle = "outer" + text.capitalize(style)
      for tab in self._children
        tabElement = self._skeletonTab(element, tab)
        tabElement[style](tabSize)
        tabBarSize += tabElement[outerStyle]()
      element[style](tabBarSize)
      self

    _skeletonFlexTabs: (style) ->
      self = this
      element = self._wrapper()
      tabBarSize = 0
      outerStyle = "outer" + text.capitalize(style)
      for tab in self._children
        tabElement = self._skeletonTab(element, tab)
        tabBarSize += tabElement[outerStyle]()
      element[style](tabBarSize)
      self

    _skeletonTab: (element, tab) ->
      tab.skeleton().element.appendTo(element)

    _key: (tab) -> tab.key()

    onrender: ->
      self = this
      for tab in self._children
        tab.render()
      super

  ###
  A scrollable tab bar looks like Google News app on Android (horizontal)
  or bookmark panel of Firefox (vertical)

  ###
  class ScrollableTabBar extends TabBar

    kls = this

    kls.widgetName "ScrollableTabBar"

    kls.configure
      scrollableClass :scrollable.Scrollable

    proto = kls.prototype
    klass.accessor proto, "scrollable"

    constructor: ->
      super
      self = this
      options = self._options
      scrollableOptions = self._extractOptions("scrollable")
      self._scrollable = new options.scrollableClass(scrollableOptions).end(self)

    onskeleton: ->
      this._scrollable.skeleton()
        .element.appendTo(this.element)
      super

    onrender: ->
      this._scrollable.render()
      super

    ondestroy: ->
      this._scrollable.destroy()
      super

    _wrapper: -> this._scrollable.container()

  Tab: Tab
  TabBar: TabBar
  ScrollableTabBar: ScrollableTabBar
