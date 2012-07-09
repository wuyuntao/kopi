define "kopi/tests/ui/touchable", (require, exports, module) ->

  $ = require "jquery"
  Touchable = require("kopi/ui/touchable").Touchable
  g = require "kopi/ui/gestures"

  class Playground extends Touchable

    this.widgetName "Playground"

    this.configure
      gestures: [g.Tap, g.Pan]

    ontap: (e) ->
      console.log "Tap", arguments

    ontaphold: (e) ->
      console.log "Tap hold", arguments

    ontaprelease: (e) ->
      console.log "Tap release", arguments

  new Playground().skeletonTo("#container").render()
