define "kopi/tests/ui/flippers", (require, exports, module) ->

  flippers = require "kopi/ui/flippers"

  flipper = new flippers.Flipper
    flippableOptions:
      scrollY: false
  page1 = new flippers.FlipperPage().skeleton(".page-1")
  page2 = new flippers.FlipperPage().skeleton(".page-2")
  page3 = new flippers.FlipperPage().skeleton(".page-3")
  page4 = new flippers.FlipperPage().skeleton(".page-4")
  page5 = new flippers.FlipperPage().skeleton(".page-5")
  flipper
    .add(page1).end()
    .add(page2).end()
    .add(page3).end()
    .add(page4).end()
    .add(page5).end()
    .skeleton(".flipper")
    .render()
