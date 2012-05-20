define "kopi/ui/lists", (require, exports, module) ->

  Group = require("kopi/ui/groups").Group
  items = require "kopi/ui/lists/items"

  class List extends Group

    this.widgetName "List"

    kls = this
    kls.configure
      # @type  {ListItem} class to build list items with
      childClass: items.ListItem
      # @type  {Boolean} If use `striped` style for lists
      striped: false
      # @type  {Boolean} If use `bordered` style for lists
      bordered: false

    onskeleton: ->
      options = this._options
      cls = this.constructor
      this.element
        .toggleClass(cls.cssClass("striped"), options.striped)
        .toggleClass(cls.cssClass("bordered"), options.bordered)
      super

  class NavList extends List

    this.widgetName "NavList"

    this.configure
      childClass: items.NavListItem
      striped: true

  List: List
  NavList: NavList
