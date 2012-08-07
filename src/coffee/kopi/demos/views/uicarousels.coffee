define "kopi/demos/views/uicarousels", (require, exports, module) ->

  array = require("kopi/utils/array")
  reverse = require("kopi/app/router").reverse
  View = require("kopi/views").View
  navigation = require("kopi/ui/navigation")
  viewswitchers = require "kopi/ui/viewswitchers"
  carousels = require("kopi/ui/carousels")

  class UICarouselView extends View

    constructor: ->
      super
      backButton = new navigation.NavButton
        url: reverse("ui")
        titleText: "Back"
      this.nav = new navigation.Nav
        title: "Carousel"
        leftButton: backButton
      this.view = new viewswitchers.View()

      this.carousel = new carousels.Carousel()

    oncreate: ->
      this.app.navbar.add(this.nav)
      this.nav.skeleton()
      this.app.viewSwitcher.add(this.view)
      this.view.skeleton()
      for i in [1..10]
        page = new carousels.CarouselPage imageSrc: "/images/pics/#{i}.jpg"
        this.carousel.add(page)
      this.carousel.skeletonTo(this.view.element)
      super

    onstart: ->
      this.app.navbar.show(this.nav)
      this.app.viewSwitcher.show(this.view)
      this.nav.render()
      this.view.render()
      this.carousel.render()
      super

    ondestroy: ->
      this.carousel.destroy()
      this.nav.destroy()
      this.view.destroy()
      super

  UICarouselView: UICarouselView
