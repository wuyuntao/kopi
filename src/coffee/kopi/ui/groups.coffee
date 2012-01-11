kopi.module("kopi.ui.groups")
  .require("kopi.exceptions")
  .require("kopi.utils.array")
  .require("kopi.ui.widgets")
  .define (exports, exceptions, array, widgets) ->

    class Group extends widgets.Widget

      this.configure
        # @option {kopi.ui.widgets.Widget} childClass
        #   Widget class which can be added to group
        childClass: widgets.Widget

      constructor: (options) ->
        super
        # @type {Array} key list of child views
        this._keys = []
        # @type {Array} list of child views
        this._children = []
        # @type {kopi.ui.widgets.Widget} active child
        this._currentChild = null

      children: -> this._children

      ###
      If a child widget is in the group
      ###
      has: (child) ->
        array.indexOf(this._keys, this._key(child)) != -1

      ###
      Add a child widget
      ###
      add: (child, options={}) ->
        this.addAt(child, options, this._keys.length)

      addAt: (child, options={}, index=0) ->
        self = this
        if not child instanceof self._options.childClass
          throw new exceptions.ValueError("Child view must be a subclass of #{self._options.childClass.name}")
        if self.has(child)
          # TODO Add custom exception
          throw new exceptions.ValueError("Already added!!!")
        child.end(self)
        array.insertAt(self._keys, index, self._key(child))
        array.insertAt(self._children, index, child)
        self._appendChild(child)
        child

      ###
      Remove a child widget
      ###
      remove: (child) ->
        index = array.indexOf(this._keys, this._key(child))
        this.removeAt(index)

      ###
      Removes the child at the specified position in the group.
      ###
      removeAt: (index) ->
        if index < 0 or index >= this._keys.length
          # TODO Add custom exception
          throw new exceptions.ValueError("Child view does not exist")
        child = this._children[index]
        if this._key(child) == this._key(this._currentChild)
          throw new exceptions.ValueError("Can not remove current view.")
        child.destroy()
        array.removeAt(this._keys, index)
        array.removeAt(this._children, index)

      ###
      Remove all child widgets
      ###
      empty: ->
        # Destroy all children
        for child in this._children
          child.destroy()
        array.empty(this._keys)
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
          index = array.indexOf(this._keys, this._key(this._currentChild))
          if index + 1 < this._keys.length
            return this._children[index + 1]

      ###
      Manually shows the previous child.
      ###
      previous: ->
        if this._currentChild
          index = array.indexOf(this._keys, this._key(this._currentChild))
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
      showAt: (index) ->
        throw new exceptions.NotImplementedError()

      ###
      Append child to wrapper element

      TODO Insert child according to its index
      ###
      _appendChild: (child) ->
        if this.initialized
          child.skeleton().element.appendTo(this._wrapper())
        if self.rendered
          child.render()

      _key: (child) -> child.guid

      onskeleton: ->
        super
        for child in this._children
          child.skeleton().element.appendTo(this._wrapper())

      onrender: ->
        super
        for child in this._children
          child.render

      ###
      Return the element which child elements should be appended to

      Override in subclasses if neccessary
      ###
      _wrapper: -> this.element

    exports.Group = Group
