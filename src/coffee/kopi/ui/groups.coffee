kopi.module("kopi.ui.groups")
  .require("kopi.exceptions")
  .require("kopi.utils.array")
  .require("kopi.ui.widgets")
  .define (exports, exceptions, array, widgets) ->

    class Group extends widgets.Widget

      this.configure
        # @type  {kopi.ui.widgets.Widget}
        childClass: widgets.Widget

      constructor: (options) ->
        super
        this._guids = []
        this._children = []
        this._currentChild = null

      ###
      If a child widget is in the group
      ###
      has: (child) ->
        array.indexOf(this._guids, child.guid) != -1

      ###
      Add a child widget
      ###
      add: (child, options={}) ->
        this.addAt(child, options, this._guids.length)

      addAt: (child, options={}, index=0) ->
        if not child instanceof this._options.childClass
          throw new exceptions.ValueError("Child view must be a subclass of #{this._options.childClass.name}")
        if this.has(child)
          throw new exceptions.ValueError("Child view already exists")
        array.insertAt(this._guids, child.guid, index)
        array.insertAt(this._children, child, index)

      ###
      Remove a child widget
      ###
      remove: (child) ->
        this.removeAt(array.indexOf(this._guids, child.guid))

      ###
      Removes the child at the specified position in the group.
      ###
      removeAt: (index) ->
        if index == -1
          throw new exceptions.ValueError("Child view does not exist")
        child = this._children[index]
        if child.guid == this._currentChild.guid
          throw new exceptions.ValueError("Can not remove current view.")
        child.destroy()
        array.removeAt(this._guids, index)
        array.removeAt(this._children, index)

      ###
      Remove all child widgets
      ###
      empty: ->
        for child in this._children
          child.destroy()
        array.empty(this._guids)
        array.empty(this._children)

      ###
      Return currently displayed child.
      ###
      current: ->
        this._currentChild

      ###
      Manually shows the next child.
      ###
      next: ->
        if this._currentChild
          index = array.indexOf(this._guids, this._currentChild.guid)
          if index + 1 < this._guids.length
            return this._children[index + 1]

      ###
      Manually shows the previous child.
      ###
      previous: ->
        if this._currentChild
          index = array.indexOf(this._guids, this._currentChild.guid)
          if index - 1 >= 0
            return this._children[index - 1]

      ###
      Manually shows the child.
      ###
      show: (child) ->
        throw new exceptions.NotImplementedError()

      ###
      Manually shows the child at the specified position in the group.
      ###
      showAt: (child) ->
        throw new exceptions.NotImplementedError()

    exports.Group = Group
