define "kopi/tests/ui/scrollable", (require, exports, module) ->

  scrollable = require "kopi/ui/scrollable"

  s = new scrollable.Scrollable(scrollX: false, damping: 0.5)
  s.skeleton(".scrollable").render()
