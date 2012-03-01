define "kopi/ui/lists", (require, exports, module) ->

  groups = require "kopi/ui/groups"
  QueueAdapter = require("kopi/ui/list/adapters").QueueAdapter
  items = require "kopi/ui/lists/items"
  klass = require "kopi/utils/klass"

  class List extends groups.Group

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
        if self._adapter and self._adapter instanceof QueueAdapter
          self._adapter.off(QueueAdapter.CHANGE_EVENT)
        if adapter and adapter instanceof QueueAdapter
          changeFn = (e) -> self.draw()
          adapter.on(QueueAdapter.CHANGE_EVENT, changeFn)

  List: List
