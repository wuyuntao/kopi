define "kopi/demos/views/uibuttons", (require, exports, module) ->

  View = require("kopi/views").View
  navigation = require("kopi/ui/navigation")
  viewswitchers = require "kopi/ui/viewswitchers"
  reverse = require("kopi/app/router").reverse
  templates = require("kopi/demos/templates/uibuttons")
  Button = require("kopi/ui/buttons").Button
  ButtonGroup = require("kopi/ui/buttongroups").ButtonGroup
  capitalize = require("kopi/utils/text").capitalize

  class UIButtonView extends View

    styles: ["default", "primary", "info", "success", "warning", "danger", "inverse"]

    sizes: ["normal", "large", "small", "mini"]

    constructor: ->
      super
      backButton = new navigation.NavButton
        url: reverse("ui")
        titleText: "Back"
      this.nav = new navigation.Nav
        title: "Buttons"
        leftButton: backButton
      this.view = new viewswitchers.View
        template: templates.buttons

      this.styleGroup = new ButtonGroup()
      for style in this.styles
        button = new Button
          titleText: capitalize(style)
          style: style
        this.styleGroup.add(button)

      this.sizeGroup = new ButtonGroup()
      for size in this.sizes
        button = new Button
          titleText: capitalize(size)
          size: size
        this.sizeGroup.add(button)

    oncreate: ->
      this.app.navBar.add(this.nav)
      this.nav.skeleton()
      this.app.viewSwitcher.add(this.view)
      this.view.skeleton()
      this.styleGroup.skeletonTo($(".button-style-section", this.view.element))
      this.sizeGroup.skeletonTo($(".button-size-section", this.view.element))
      super

    onstart: ->
      this.app.navBar.show(this.nav)
      this.app.viewSwitcher.show(this.view)
      this.nav.render()
      this.view.render()
      this.styleGroup.render()
      this.sizeGroup.render()
      super

    ondestroy: ->
      this.styleSection.destroy()
      this.sizeGroup.destroy()
      this.nav.destroy()
      this.view.destroy()
      super

  UIButtonView: UIButtonView
