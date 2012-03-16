define "kopi/ui/buttongroups", (require, exports, module) ->

  Group = require "kopi/ui/groups"

  ###
  Presents a group of buttons
  ###
  class ButtonGroup extends Group

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
