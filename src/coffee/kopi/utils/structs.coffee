kopi.module("kopi.utils.structs")
  .require("kopi.utils.map")
  .require("kopi.utils.weakmap")
  .define (exports, utils) ->

    exports.WeakMap = weakmap.WeakMap
    exports.Map = map.Map
