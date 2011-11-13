kopi.module("kopi.ui.adapters")
  .require("kopi.events")
  .define (exports, events) ->

    class Adapter extends events.EventEmitter


    exports.Adapter = Adapter
