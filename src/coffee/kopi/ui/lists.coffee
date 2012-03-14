define "kopi/ui/lists", (require, exports, module) ->

  exceptions = require "kopi/exceptions"
  groups = require "kopi/ui/groups"
  QueueAdapter = require("kopi/ui/lists/adapters").QueueAdapter
  items = require "kopi/ui/lists/items"
  klass = require "kopi/utils/klass"

  class List extends groups.Group

    this.widgetName "List"

    kls = this
    kls.configure
      childClass: items.ListItem

    proto = kls.prototype
    ###
    Accessor for adapter

    When changing adapter, redraw whole list
    ###
    klass.accessor proto, "adapter",
      set: (adapter) ->
        self = this
        # Remove event listeners if previous adapter is a queue adapter
        if self._adapter and self._adapter instanceof QueueAdapter
          self._adapter.off(QueueAdapter.CHANGE_EVENT)

        self._adapter = adapter
        # Add event listeners if current adapter is a queue adapter
        if adapter and adapter instanceof QueueAdapter
          changeFn = (e) -> self.renderItems()
          adapter.on(QueueAdapter.CHANGE_EVENT, changeFn)

    onrender: ->
      this.renderItems()
      super

    ###
    Render all items included in the adapter
    ###
    renderItems: ->
      self = this
      if not self._adapter
        throw new exceptions.ValueError("Missing adapter")
      # Remove old items
      while self._children.length
        self.removeAt(0)
      # Create from adapter
      itemClass = self._options.childClass
      self._adapter.forEach (data, i) ->
        item = new itemClass(self, data)
        self.addAt(item, i)
      self

  class NavList extends List

    this.configure
      childClass: items.NavListItem

  List: List
  NavList: NavList
