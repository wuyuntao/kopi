define "kopi/ui/switchers", (require, exports, module) ->

  exceptions = require "kopi/exceptions"
  logging = require "kopi/logging"
  array = require "kopi/utils/array"
  klass = require "kopi/utils/klass"
  groups = require "kopi/ui/groups"

  logger = logging.logger(module.id)

  HIDE = "hide"
  SHOW = "show"
  CURRENT = "current"

  class Switcher extends groups.Group

    constructor: ->
      super
      # @type {Number} active child
      this._currentKey = null

    removeAt: (index) ->
      if index == this._currentChildIndex
        throw new exceptions.ValueError("Can not remove current view.")
      super(index)

    ###
    Return currently displayed child.
    ###
    current: ->
      this._children[this.currentAt()]

    ###
    Return index of currently displayed child
    ###
    currentAt: ->
      array.indexOf(this._keys, this._currentKey)

    ###
    Manually show the next child.
    ###
    showNext: ->
      index = this.currentAt()
      if index? and index + 1 < this._keys.length
        this.showAt(index + 1)
      this

    ###
    Manually show the previous child.
    ###
    showPrevious: ->
      index = this.currentAt()
      if index? and index >= 1
        this.showAt(index - 1)
      this

    ###
    Manually show the child at the specified position in the group.
    ###
    showAt: (index) ->
      self = this
      unless 0 <= index < self._children.length
        throw new exceptions.ValueError("Invalid index of child #{index} of #{self._children.length}")

      # Do nothing if index is referring to current child
      currentAt = self.currentAt()
      if currentAt and currentAt == index
        logger.warn("Child is already active.")
        return self

      self.lock()
      child = self._children[index]

      # Shows child directly if there is no current child
      if not currentAt >= 0
        self._show(child)
        return self

      currentChild = self._children[currentAt]
      hidden = false
      shown = false
      doneFn = ->
        if hidden and shown
          self._currentKey = self._key(child)
          self.unlock()
      hideFn = (error) ->
        hidden = true
        doneFn()
      showFn = (error) ->
        shown = true
        doneFn()
      self._hide(currentChild, hideFn)._show(child, showFn)

    ###
    Manually show the child
    ###
    show: (child) ->
      this.showAt(this.indexOf(child))

    ###
    Show the child.
    ###
    _show: (child, fn) ->
      cls = this.constructor
      child.element.addClass("#{cls.cssClass(SHOW)} #{cls.cssClass(CURRENT)}")
      this._currentKey = this._key(child)
      fn(null) if fn
      this

    ###
    Hide the child.
    ###
    _hide: (child, fn) ->
      cls = this.constructor
      child.element.removeClass("#{cls.cssClass(SHOW)} #{cls.cssClass(CURRENT)}")
      fn(null) if fn
      this

  Switcher: Switcher
