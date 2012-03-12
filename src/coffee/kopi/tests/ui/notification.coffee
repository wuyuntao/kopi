define "kopi/tests/ui/notification", (require, exports, module) ->

  overlays = require "kopi/ui/notification/overlays"
  indicators = require "kopi/ui/notification/indicators"
  bubbles = require "kopi/ui/notification/bubbles"
  dialogs = require "kopi/ui/notification/dialogs"

  $ ->
    $("#show-overlay").click ->
      overlays.show()
      console.log "Hide overlay in 3 seconds."
      setTimeout (-> overlays.hide()), 3000

    $("#show-indicator").click ->
      indicators.show()
      console.log "Hide indicator in 3 seconds."
      setTimeout (-> indicators.hide()), 3000

    $("#show-bubble").click ->
      bubbles.show "Hello world!",
        lock: true
        transparent: false
        duration: 3000

    $("#show-dialog").click ->
      dialogs.instance()
        .title("Hello world!")
        .content("This is a dialog!")
        .action("Confirm", -> console.log("Action button clicked"))
        .close("Cancel", -> console.log("Close button clicked"))
        .show()
