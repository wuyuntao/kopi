define "kopi/ui/lists/items", (require, exports, module) ->

  buttons = require "kopi/ui/buttons"
  widgets = require "kopi/ui/widgets"
  lists = require "kopi/ui/lists"

  ###
  Base class of list items
  ###
  class BaseListItem extends widgets.Widget

    constructor: (list, options) ->
      super(options)
      this.list = list

  ###
  A simple list item filled with button
  ###
  class ListItem extends BaseListItem

    constructor: (list, text)->
      super(list)
      this.register("button", buttons.Button, hasIcon: false)
      this._button.text(text)

  BaseListItem: BaseListItem
  ListItem: ListItem
