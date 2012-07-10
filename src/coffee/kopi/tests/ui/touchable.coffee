define "kopi/tests/ui/touchable", (require, exports, module) ->

  $ = require "jquery"
  Touchable = require("kopi/ui/touchable").Touchable
  g = require "kopi/ui/gestures"

  class CustomGesture extends g.Base

    this.configure
      preventDefault: true

    constructor: ->
      super
      this._previousTaps = []

    ontouchstart: (e) ->
      this.reset()

    ontouchmove: (e) ->

    ontouchend: (e) ->

    ontouchcancel: (e) -> this.touchend(e)

    reset: ->


  class PhotoGallery extends Touchable

    this.widgetName "PhotoGallery"

    this.configure
      gestures: [CustomGesture]

    onskeleton: ->

    onrender: ->

  $ ->
    new PhotoGallery().skeleton("#container").render()
