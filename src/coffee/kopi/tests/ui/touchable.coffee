define "kopi/tests/ui/touchable", (require, exports, module) ->

  $ = require "jquery"
  Touchable = require("kopi/ui/touchable").Touchable
  g = require "kopi/ui/gestures"

  class CustomGesture extends g.Base

    this.configure
      preventDefault: true

    constructor: ->
      super

    ontouchstart: (e) ->
      this._startPos = this._getPosition(e)
      this._startTime = new Date()
      this._startTouches = this._getTouches(e)
      this._startEvent = e
      this._setHoldTimeout(event)

    ontouchmove: (e) ->

    ontouchend: (e) ->

    ontouchcancel: (e) -> this.touchend(e)

    _setHoldTimeout: (e) ->

  class PhotoGallery extends Touchable

    this.widgetName "PhotoGallery"

    this.configure
      gestures: [CustomGesture]

    constructor: ->
      super
      this.images = []

    onskeleton: ->
      super

    onrender: ->
      $("img", this.element).each =>
        img = $(this)
        img
          .data("width", this.width)
          .data("height", this.height)
        this.images.push(img)
      super

  $ ->
    new PhotoGallery()
      .skeleton("#container")
      .render()
