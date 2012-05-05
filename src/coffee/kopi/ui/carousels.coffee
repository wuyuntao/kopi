define "kopi/ui/carousel", (require, exports, module) ->

  klass = require("kopi/utils/klass")
  flippers = require("kopi/ui/flippers")
  Image = require("kopi/ui/images").Image

  class CarouselPage extends flippers.FlipperPage

    this.widgetName "CarouselPage"

    constructor: ->
      super
      this.register "image", Image,
        loadSrc: "/images/kopi/loader.gif"
        width: 480
        height: 320

  class Carousel extends flippers.Flipper

    this.widgetName "Carousel"

    this.configure
      childClass: CarouselPage

  CarouselPage: CarouselPage
  Carousel: Carousel
