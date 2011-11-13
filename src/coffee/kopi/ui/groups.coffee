kopi.module("kopi.ui.groups")
  .require("kopi.exceptions")
  .require("kopi.utils.klass")
  .require("kopi.ui.widgets")
  .define (exports, exceptions, klass, widgets) ->

    class GroupChild extends widgets.Widget

      # this.PREVIOUS = "previous"
      # this.CURRENT = "current"
      # this.NEXT = "next"
      # this.states = [this.PREVIOUS, this.CURRENT, this.NEXT]

    class Group extends widgets.Widget

      this.configure
        childClass: GroupChild

      constructor: (element, options, data) ->
        super
        this.children = []

      ###
      If a child widget is in the group
      ###
      has: (child) ->
        throw new exceptions.NotImplementedError()

      ###
      Add a child widget
      ###
      add: (child, options={}) ->
        throw new exceptions.NotImplementedError()

      ###
      Remove a child widget
      ###
      remove: (child) ->
        throw new exceptions.NotImplementedError()

      ###
      Removes the child at the specified position in the group.
      ###
      removeAt: (index) ->
        throw new exceptions.NotImplementedError()

      ###
      Remove all child widgets
      ###
      empty: () ->
        throw new exceptions.NotImplementedError()

      ###
      Return currently displayed child.
      ###
      current: () ->
        throw new exceptions.NotImplementedError()

      ###
      Manually shows the next child.
      ###
      next: ->
        throw new exceptions.NotImplementedError()

      ###
      Manually shows the previous child.
      ###
      previous: ->
        throw new exceptions.NotImplementedError()

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
