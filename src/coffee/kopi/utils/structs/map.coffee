define "kopi/utils/structs/map", (require, exports, module) ->

  weakmap = require "kopi/utils/structs/weakmap"

  ###
  Similar in style to weak maps.

  ###
  class Map extends weakmap.WeakMap

  Map: Map
