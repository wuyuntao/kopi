define "kopi/tests/ui/buttons", (require, exports, module) ->

  buttons = require "kopi/ui/buttons"

  button = new buttons.Button
    hasIcon: false,
    onhover: -> console.log("hover")
    onhoverout: -> console.log("hoverout")
    onclick: -> console.log("click")
    ontouchhold: -> console.log("touchhold")
  button.text("button").skeleton("#button1").render()

  return
