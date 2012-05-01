define "kopi/ui/groups", (require, exports, module) ->

  exceptions = require "kopi/exceptions"
  array = require "kopi/utils/array"
  widgets = require "kopi/ui/widgets"

  class Group extends widgets.Widget

    this.widgetName "Group"

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

    children: -> this._children

    ###
    Return child which is at index
    ###
    getAt: (index) ->
      this._children[index]

    indexOf: (child) ->
      array.indexOf(this._keys, this._key(child))

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
      unless 0 <= index < this._keys.length
        # TODO Add custom exception
        throw new exceptions.ValueError("Child view does not exist")
      child.destroy()
      array.removeAt(this._keys, index)
      array.removeAt(this._children, index)
      this

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
    Append child to wrapper element

    TODO Insert child according to its index
    ###
    _appendChild: (child) ->
      self = this
      if self.initialized
        child.skeletonTo(self._wrapper())
      if self.rendered
        child.render()

    _key: (child) -> child.guid

    onskeleton: ->
      this._skeletonChildren()
      super

    onrender: ->
      this._renderChildren()
      super

    _skeletonChildren: ->
      wrapper = this._wrapper()
      for child in this._children
        child.skeleton().element.appendTo(wrapper)

    _renderChildren: ->
      for child in this._children
        child.render()

    ###
    Return the element which child elements should be appended to

    Override in subclasses if neccessary
    ###
    _wrapper: -> this.element

  Group: Group
