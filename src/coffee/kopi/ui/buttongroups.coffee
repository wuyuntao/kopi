define "kopi/ui/buttongroups", (require, exports, module) ->

  Button = require("kopi/ui/buttons").Button
  Group = require("kopi/ui/groups").Group

  ###
  A `ButtonGroup` joins multiple buttons together as one composite component.
  ###
  class ButtonGroup extends Group

    this.widgetName "ButtonGroup"

    this.configure
      childClass: Button
      # @type  {Boolean} If remove gaps between buttons
      together: true

  ###
  A group of buttons acts as checkbox inputs
  ###
  class CheckboxButtonGroup extends ButtonGroup

  ###
  A group of buttons acts as radio inputs
  ###
  class RadioButtonGroup extends ButtonGroup

  ButtonGroup: ButtonGroup
  CheckboxButtonGroup: CheckboxButtonGroup
