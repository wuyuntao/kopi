kopi.module("kopi.ui.slidable")
  .require("kopi.ui.groups")
  .require("kopi.ui.scrollable")
  .define (exports, groups, scrollable) ->

    ###
    Base class for slideshow and view flipper widgets, which can be snap to certain element

    ###
    class Slidable extends scrollable.Scrollable

      constructor: (group, options) ->
        super(options)
        this._group = group
        # Make sure snap is true
        options.snap = true

      _size: ->

      _snap: (x, y) ->

    class SlideShow extends groups.Group

    exports.Slidable = Slidable
