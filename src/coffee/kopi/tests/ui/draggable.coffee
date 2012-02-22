define "kopi/tests/ui/draggable", (require, exports, module) ->

  draggable = require "kopi/ui/draggable"

  d = new draggable.Draggable().skeleton(".draggable").render()
