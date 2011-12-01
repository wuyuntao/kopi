kopi.module("kopi.ui.images")
  .require("kopi.ui.widgets")
  .define (exports, widgets) ->

    class Image extends widgets.Widget

      this.configure
        tagName: "img"

    exports.Image = Image
